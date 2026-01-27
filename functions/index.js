const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

exports.createMpPreference = functions.https.onCall(async (data) => {
  try {
    const {
      amount,
      barberId,
      dateKey,
      hourKey,
      clientName,
      service,
      appointmentId,
    } = data;

    const parsedAmount = Number(amount);
    if (Number.isNaN(parsedAmount) || parsedAmount <= 0) {
      throw new functions.https.HttpsError("invalid-argument", "Monto inválido");
    }

    const mpToken = functions.config().mp.token;

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
        external_reference: appointmentId, // ⭐ CLAVE
        metadata: {
          barberId,
          dateKey,
          hourKey,
          clientName,
          service,
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
      init_point: response.data.init_point,
    };
  } catch (error) {
    console.error("🔥 MP ERROR REAL:", error.response?.data || error);
    throw new functions.https.HttpsError("internal", "Error creando preferencia");
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

    const { status, external_reference } = mpRes.data;
    if (!external_reference) return res.sendStatus(200);

    const appointmentRef = admin.database().ref(`appointments/${external_reference}`);

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

    res.sendStatus(200);
  } catch (err) {
    console.error("🔥 WEBHOOK ERROR:", err);
    res.sendStatus(500);
  }
});

