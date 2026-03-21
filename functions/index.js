/**
 * Firebase Functions v2 – Mercado Pago
 * SOLO TARJETA – versión estable para reservas (SAFE)
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
   CREATE PREFERENCE  (NO crea cita todavía)
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
      phone
    } = request.data || {};

    if (!appointmentId) {
      throw new HttpsError("invalid-argument", "appointmentId requerido");
    }

    const parsedAmount = Number(amount);
    if (Number.isNaN(parsedAmount) || parsedAmount <= 0) {
      throw new HttpsError("invalid-argument", "Monto inválido");
    }

    /* 🔥 guardamos SOLO intención (NO cita real) */
    await admin.database().ref(`pendingPayments/${appointmentId}`).set({
      barberId,
      clientName,
      service,
      dateKey,
      hourKey,
      amount: parsedAmount,
      createdAt: admin.database.ServerValue.TIMESTAMP,
      phone
    });

    const barberSnap = await admin.database()
      .ref(`barbers/${barberId}`)
      .get();

    if (!barberSnap.exists() || !barberSnap.val().mpAccessToken) {
      throw new HttpsError(
        "failed-precondition",
        "El barbero no tiene Mercado Pago conectado"
      );
    }

    const barberToken = barberSnap.val().mpAccessToken;

    const baseUrl = "https://shelbybarber.net";

    try {
      const response = await axios.post(
        "https://api.mercadopago.com/checkout/preferences",
        {
          items: [
            {
              title: `Pago - ${service}`,
              quantity: 1,
              currency_id: "MXN",
              unit_price: parsedAmount,
            },
          ],

          external_reference: appointmentId,

          payment_methods: {
            excluded_payment_types: [
              { id: "ticket" },
              { id: "atm" },
              { id: "bank_transfer" }
            ],
            installments: 1
          },
          application_fee: 5,
          back_urls: {
            success: `${baseUrl}/payment-result?id=${appointmentId}`,
            failure: `${baseUrl}/payment-result?id=${appointmentId}`,
          },

          auto_return: "approved",
        },
        {
          headers: {
            Authorization: `Bearer ${barberToken}`,
          },
        }
      );

      return { init_point: response.data.init_point };

    } catch (err) {
      console.error("🔥 MP CREATE ERROR:", err.response?.data || err);
      throw new HttpsError("internal", "Error creando preferencia");
    }
  }
);


/* =======================================================
   WEBHOOK (ÚNICA fuente de verdad)
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
          headers: { Authorization: `Bearer ${MP_TOKEN}` },
        }
      );

      const {
        status,
        external_reference: appointmentId,
        transaction_amount,
      } = mpRes.data;

      if (!appointmentId) return res.status(200).send("ok");

      const pendingRef =
        admin.database().ref(`pendingPayments/${appointmentId}`);

      const snap = await pendingRef.get();
      if (!snap.exists()) return res.status(200).send("ok");

      const data = snap.val();

      if (Number(transaction_amount) !== Number(data.amount)) {
        return res.status(200).send("ok");
      }

      /* 🔥 SOLO AQUÍ creamos la cita REAL */
      if (status === "approved") {

        await admin.database()
          .ref(`appointments/${appointmentId}`)
          .set({
            ...data,
            paid: true,
            paymentStatus: "approved",
            paidAt: admin.database.ServerValue.TIMESTAMP,
          });

        await pendingRef.remove();
      }

      console.log("✅ webhook ok:", appointmentId, status);

      return res.status(200).send("ok");

    } catch (err) {
      console.error("🔥 WEBHOOK ERROR:", err);
      return res.status(200).send("ok");
    }
  }
);

/* =======================================================
   OAUTH CONNECT BARBER
======================================================= */
exports.exchangeMpCode = onCall(
  { secrets: ["MP_TOKEN"] },
  async (request) => {

    const { code, uid } = request.data;

    if (!code || !uid) {
      throw new HttpsError("invalid-argument", "code/uid requeridos");
    }

    const MP_TOKEN = process.env.MP_TOKEN;

    try {
      const res = await axios.post(
        "https://api.mercadopago.com/oauth/token",
        {
          grant_type: "authorization_code",
          client_secret: MP_TOKEN,
          code,
          redirect_uri: "https://dashboardshelby.netlify.app/mp-callback",
        }
      );

      await admin.database()
        .ref(`barbers/${uid}`)
        .update({
          mpAccessToken: res.data.access_token,
          mpConnected: true,
        });

      return { ok: true };

    } catch (err) {
      console.error(err.response?.data || err);
      throw new HttpsError("internal", "MP OAuth error");
    }
  }
);
