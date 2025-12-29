const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { google } = require('googleapis');

admin.initializeApp();

// Obtener configuración de environment variables
const getConfig = () => {
  const config = functions.config();
  
  if (!config.google || !config.google.calendar) {
    throw new Error('Google Calendar config not found');
  }
  
  return {
    client_email: config.google.calendar.client_email,
    private_key: config.google.calendar.private_key.replace(/\\n/g, '\n'),
    project_id: config.google.calendar.project_id,
    barber_calendars: {
      fernando: config.barber?.fernando?.calendar_id,
      jorge: config.barber?.jorge?.calendar_id
    }
  };
};

// Función principal: Agregar cita al calendario del barbero
exports.addAppointmentToBarberCalendar = functions.firestore
    .document('appointments/{appointmentId}')
    .onCreate(async (snap, context) => {
        console.log('🚀 Nueva cita detectada:', context.params.appointmentId);
        
        try {
            const appointmentData = snap.data();
            const barberId = appointmentData.barberId;
            
            console.log(`📝 Procesando cita para barbero: ${barberId}`);
            
            const config = getConfig();
            const barberCalendarId = config.barber_calendars[barberId];
            
            if (!barberCalendarId) {
                console.log(`❌ No se encontró calendario para el barbero: ${barberId}`);
                await snap.ref.update({
                    calendarError: `No calendar configured for barber: ${barberId}`,
                    calendarAdded: false
                });
                return null;
            }
            
            console.log(`📅 Calendario encontrado: ${barberCalendarId}`);
            
            // Configurar autenticación con Google
            const auth = new google.auth.JWT(
                config.client_email,
                null,
                config.private_key,
                ['https://www.googleapis.com/auth/calendar']
            );
            
            const calendar = google.calendar({ version: 'v3', auth });
            
            // Preparar fechas del evento
            const appointmentDate = appointmentData.date.toDate();
            const endDate = new Date(appointmentDate.getTime() + (appointmentData.serviceDuration * 60000));
            
            console.log(`🕐 Fecha de cita: ${appointmentDate.toISOString()}`);
            
            // Crear evento para el calendario
            const event = {
                summary: `✂️ ${appointmentData.service} - ${appointmentData.name}`,
                description: `🏪 CITA DE TRABAJO AUTOMÁTICA\n\n` +
                    `👤 Cliente: ${appointmentData.name}\n` +
                    `📞 Teléfono: ${appointmentData.phone}\n` +
                    `✂️ Servicio: ${appointmentData.service}\n` +
                    `⏱️ Duración: ${appointmentData.serviceDuration} minutos\n` +
                    `💰 Estado: ${appointmentData.status}\n` +
                    `🆔 ID: ${context.params.appointmentId}\n\n` +
                    `📱 Agendada automáticamente desde Barbería App\n` +
                    `⚠️ No eliminar manualmente - usar la app para cancelar`,
                start: {
                    dateTime: appointmentDate.toISOString(),
                    timeZone: 'America/Mexico_City',
                },
                end: {
                    dateTime: endDate.toISOString(),
                    timeZone: 'America/Mexico_City',
                },
                reminders: {
                    useDefault: false,
                    overrides: [
                        { method: 'popup', minutes: 15 },  // 15 min antes
                        { method: 'email', minutes: 60 }   // 1 hora antes
                    ]
                },
                colorId: '10', // Verde para citas de trabajo
                transparency: 'opaque', // Marcar como ocupado
            };
            
            console.log('📤 Creando evento en Google Calendar...');
            
            // Insertar evento en Google Calendar
            const response = await calendar.events.insert({
                calendarId: barberCalendarId,
                resource: event,
                sendUpdates: 'none' // No enviar emails automáticos
            });
            
            console.log(`✅ Evento creado exitosamente: ${response.data.id}`);
            
            // Actualizar documento en Firestore
            await snap.ref.update({
                googleCalendarEventId: response.data.id,
                googleCalendarLink: response.data.htmlLink,
                calendarAdded: true,
                calendarAddedAt: admin.firestore.FieldValue.serverTimestamp()
            });
            
            console.log('💾 Documento actualizado en Firestore');
            
            return {
                success: true,
                eventId: response.data.id,
                barberId: barberId
            };
            
        } catch (error) {
            console.error('❌ Error al agregar cita al calendario:', error);
            
            // Guardar error en Firestore para debug
            await snap.ref.update({
                calendarError: error.message,
                calendarErrorDetails: error.stack,
                calendarAdded: false,
                calendarErrorAt: admin.firestore.FieldValue.serverTimestamp()
            });
            
            return {
                success: false,
                error: error.message
            };
        }
    });

// Función para cancelar/eliminar citas del calendario
exports.updateBarberCalendarAppointment = functions.firestore
    .document('appointments/{appointmentId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();
        
        // Solo procesar si cambió el status a 'cancelled'
        if (before.status !== 'cancelled' && after.status === 'cancelled') {
            console.log('🗑️ Cita cancelada, eliminando del calendario:', context.params.appointmentId);
            
            try {
                const config = getConfig();
                const barberId = after.barberId;
                const barberCalendarId = config.barber_calendars[barberId];
                const eventId = after.googleCalendarEventId;
                
                if (barberCalendarId && eventId) {
                    const auth = new google.auth.JWT(
                        config.client_email,
                        null,
                        config.private_key,
                        ['https://www.googleapis.com/auth/calendar']
                    );
                    
                    const calendar = google.calendar({ version: 'v3', auth });
                    
                    await calendar.events.delete({
                        calendarId: barberCalendarId,
                        eventId: eventId
                    });
                    
                    console.log(`✅ Evento eliminado del calendario: ${eventId}`);
                    
                    // Actualizar documento
                    await change.after.ref.update({
                        calendarRemovedAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                }
            } catch (error) {
                console.error('❌ Error al eliminar evento del calendario:', error);
            }
        }
        
        return null;
    });

// Función de prueba (opcional - para testing)
exports.testCalendarConnection = functions.https.onRequest(async (req, res) => {
    try {
        const config = getConfig();
        
        const auth = new google.auth.JWT(
            config.client_email,
            null,
            config.private_key,
            ['https://www.googleapis.com/auth/calendar']
        );
        
        const calendar = google.calendar({ version: 'v3', auth });
        
        // Listar calendarios para verificar acceso
        const response = await calendar.calendarList.list();
        
        res.json({
            success: true,
            message: 'Conexión exitosa a Google Calendar',
            calendars: response.data.items?.map(cal => ({
                id: cal.id,
                summary: cal.summary,
                accessRole: cal.accessRole
            }))
        });
        
    } catch (error) {
        console.error('Error en test de conexión:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});