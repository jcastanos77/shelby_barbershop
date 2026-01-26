const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

exports.createMpPreference = functions.https.onCall(async (data, context) => {
  try {

    const {
      amount,
      barberId,
      dateKey,
      hourKey,
      clientName,
      service,
    } = data.data;

    const parsedAmount = Number(amount);


    if (Number.isNaN(parsedAmount)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "El monto no es un número"
      );
    }

    if (parsedAmount <= 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "El monto debe ser mayor a 0"
      );
    }

    const mpToken = functions.config().mp.token;
    if (!mpToken) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Token MP no configurado"
      );
    }

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
        metadata: {
          barberId,
          dateKey,
          hourKey,
          clientName,
        },
        back_urls: {
          success: "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=approved",
          failure: "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=rejected",
          pending: "https://neon-seahorse-b85142.netlify.app/#/payment-result?status=pending",
        },
       auto_return: "approved",
      },
      {
        headers: {
          Authorization: `Bearer ${mpToken}`,
        },
      }
    );

    return {
      preferenceId: response.data.id,
      init_point: response.data.init_point,
    };

  } catch (error) {
    console.error("🔥 MP ERROR REAL:", error.response?.data || error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      "internal",
      "Error interno creando preferencia"
    );
  }
});

exports.mpWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const paymentId = req.body?.data?.id;
    if (!paymentId) return res.sendStatus(200);

    const mpRes = await axios.get(
      `https://api.mercadopago.com/v1/payments/${paymentId}`,
      {
        headers: {
          Authorization: `Bearer ${functions.config().mp.token}`,
        },
      }
    );

    const { status, metadata } = mpRes.data;
    const appointmentId = metadata?.appointmentId;

    if (!appointmentId) return res.sendStatus(200);

    if (status === "approved") {
      await admin.database()
        .ref(`appointments/${appointmentId}`)
        .update({
          paid: true,
          paymentStatus: "approved",
          paidAt: admin.database.ServerValue.TIMESTAMP,
        });
    } else {
      await admin.database()
        .ref(`appointments/${appointmentId}`)
        .update({
          paymentStatus: status,
        });
    }

    res.sendStatus(200);
  } catch (err) {
    console.error("🔥 WEBHOOK ERROR:", err);
    res.sendStatus(500);
  }
});

