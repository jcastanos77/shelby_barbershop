/**
 * Firebase Functions v2 – Mercado Pago (PROD)
 * Hardened version
 */

const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

/**
 * Opciones globales (costos + estabilidad)
 */
setGlobalOptions({
  region: "us-central1",
  timeoutSeconds: 30,
  memory: "256MiB",
});

/**
 * ============================
 * Crear preferencia de pago
 * Callable (requiere auth)
 * ============================
 */
exports.createMpPreference = onCall(
  { secrets: ["MP_TOKEN"] },
  async (request) => {
    /** 🔐 Auth obligatoria */
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Debes estar autenticado para iniciar un pago"
      );
    }

    const {
      amount,
      barberId,
      dateKey,
      hourKey,
      clientName,
      service,
      appointmentId,
    } = request.data || {};

    /** 🧪 Validaciones duras */
    if (!appointmentId) {
      throw new HttpsError("invalid-argument", "appointmentId requerido");
    }

    const parsedAmount = Number(amount);
    if (Number.isNaN(parsedAmount) || parsedAmount <= 0) {
      throw new HttpsError("invalid-argument", "Monto inválido");
    }

    if (!barberId || !dateKey || !hourKey || !clientName || !service) {
      throw new HttpsError("invalid-argument", "Datos incompletos");
    }

    const MP_TOKEN = process.env.MP_TOKEN;
    if (!MP_TOKEN) {
      throw new HttpsError("failed-precondition", "MP_TOKEN no configurado");
    }

    try {
      const response = await axios.post(
        "https://api.mercadopago.com/checkout/preferences",
        {
          items: [
            {
              title: `Anticipo - ${service}`,
              quantity: 1,
              currency_id: "MXN",
              unit_price: parsedAmount,
            },
          ],

          /** 🔗 Referencia dura para webhook */
          external_reference: appointmentId,

          metadata: {
            barberId,
            dateKey,
            hourKey,
            clientName,
            service,
          },

          back_urls: {
            success:
              "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=approved",
            failure:
              "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=rejected",
            pending:
              "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=pending",
          },

          auto_return: "approved",
        },
        {
          headers: {
            Authorization: `Bearer ${MP_TOKEN}`,
          },
        }
      );

      return {
        init_point: response.data.init_point,
      };
    } catch (err) {
      console.error("🔥 MP CREATE ERROR:", err.response?.data || err);

      throw new HttpsError(
        "internal",
        "No se pudo crear la preferencia de pago"
      );
    }
  }
);

/**
 * ============================
 * Webhook Mercado Pago
 * ============================
 */
exports.mpWebhook = onRequest(
  { secrets: ["MP_TOKEN"] },
  async (req, res) => {
    try {
      const paymentId = req.body?.data?.id;
      if (!paymentId) {
        return res.status(200).send("ok");
      }

      const MP_TOKEN = process.env.MP_TOKEN;

      const mpRes = await axios.get(
        `https://api.mercadopago.com/v1/payments/${paymentId}`,
        {
          headers: {
            Authorization: `Bearer ${MP_TOKEN}`,
          },
        }
      );

      const {
        status,
        external_reference: appointmentId,
        transaction_amount,
      } = mpRes.data;

      if (!appointmentId) {
        return res.status(200).send("ok");
      }

      const appointmentRef = admin
        .database()
        .ref(`appointments/${appointmentId}`);

      const snapshot = await appointmentRef.get();
      if (!snapshot.exists()) {
        return res.status(200).send("ok");
      }

      const appointment = snapshot.val();

      /** 🛑 Evita reprocesar */
      if (appointment.paid === true) {
        return res.status(200).send("ok");
      }

      /** 🛡️ Antifraude básico */
      if (transaction_amount !== appointment.amount) {
        console.warn(
          "Monto no coincide",
          transaction_amount,
          appointment.amount
        );
        return res.status(200).send("ok");
      }

      if (status === "approved") {
        await appointmentRef.update({
          paid: true,
          paymentStatus: "approved",
          paidAt: admin.database.ServerValue.TIMESTAMP,
        });
      } else {
        await appointmentRef.update({
          paymentStatus: status,
        });
      }

      return res.status(200).send("ok");
    } catch (err) {
      console.error("🔥 WEBHOOK ERROR:", err);
      return res.status(500).send("error");
    }
  }
);
