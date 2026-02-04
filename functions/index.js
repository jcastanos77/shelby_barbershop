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
              "https://neon-seahorse-b85142.netlify.app/#/payment-result?id=${appointmentId}&status=approved",
            failure:
              "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=rejected",
            pending:
              "https://neon-seahorse-b85142.netlify.app/#/payment-result?id=${appointmentId}&status=pending",
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
 * Webhook Mercado Pago (PUBLICO)
 * NO secrets
 * NO auth
 * ============================
 */
exports.mpWebhook = onRequest(
  { secrets: ["MP_TOKEN"] }, // 👈 NECESARIO
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

      const ref = admin.database().ref(`appointments/${appointmentId}`);
      const snap = await ref.get();

      if (!snap.exists()) {
        return res.status(200).send("ok");
      }

      const appointment = snap.val();

      if (Number(transaction_amount) !== Number(appointment.amount)) {
        return res.status(200).send("ok");
      }

      await ref.update({
        paid: status === "approved",
        paymentStatus: status,
        paidAt: admin.database.ServerValue.TIMESTAMP,
      });

      console.log("✅ webhook ok:", appointmentId, status);

      return res.status(200).send("ok");
    } catch (err) {
      console.error("🔥 WEBHOOK ERROR:", err);
      return res.status(200).send("ok"); //
    }
  }
);
