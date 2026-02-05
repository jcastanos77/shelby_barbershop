/**
 * Firebase Functions v2 – Mercado Pago
 * SOLO TARJETA – versión estable para reservas
 */

const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

setGlobalOptions({
  region: "us-central1",
  timeoutSeconds: 30,
  memory: "256MiB",
});

/* =======================================================
   CREATE PREFERENCE  (SOLO TARJETA)
======================================================= */
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

    if (!appointmentId) {
      throw new HttpsError("invalid-argument", "appointmentId requerido");
    }

    const parsedAmount = Number(amount);
    if (Number.isNaN(parsedAmount) || parsedAmount <= 0) {
      throw new HttpsError("invalid-argument", "Monto inválido");
    }

    const MP_TOKEN = process.env.MP_TOKEN;
    if (!MP_TOKEN) {
      throw new HttpsError("failed-precondition", "MP_TOKEN faltante");
    }

    try {
      const baseUrl =
        "https://neon-seahorse-b85142.netlify.app"; // 👈 cambia si cambias dominio

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

          external_reference: appointmentId,

          metadata: {
            barberId,
            dateKey,
            hourKey,
            clientName,
            service,
          },
          payment_methods: {
            excluded_payment_types: [
              { id: "ticket" },        // OXXO / efectivo
              { id: "atm" },
              { id: "bank_transfer" }
            ],
            installments: 1
          },

          back_urls: {
            success: `${baseUrl}/payment-result?status=approved&id=${appointmentId}`,
            failure: `${baseUrl}/payment-result?status=rejected&id=${appointmentId}`,
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
      throw new HttpsError("internal", "Error creando preferencia");
    }
  }
);

/* =======================================================
   WEBHOOK (confirmación real)
======================================================= */
exports.mpWebhook = onRequest(
  { secrets: ["MP_TOKEN"] },
  async (req, res) => {
    try {
      const paymentId = req.body?.data?.id;
      if (!paymentId) return res.status(200).send("ok");

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

      if (!appointmentId) return res.status(200).send("ok");

      const ref = admin.database().ref(`appointments/${appointmentId}`);
      const snap = await ref.get();

      if (!snap.exists()) return res.status(200).send("ok");

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
      return res.status(200).send("ok");
    }
  }
);
