const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.createMpPreference = functions.https.onCall(async (data) => {
  const {
    amount,
    barberId,
    dateKey,
    hourKey,
    clientName,
    service,
  } = data;

  const response = await axios.post(
    "https://api.mercadopago.com/checkout/preferences",
    {
      items: [
        {
          title: `Anticipo - ${service}`,
          quantity: 1,
          currency_id: "MXN",
          unit_price: amount,
        },
      ],
      metadata: {
        barberId,
        dateKey,
        hourKey,
      },
      back_urls: {
         success: "https://neon-seahorse-b85142.netlify.app/payment-result?clientName=${clientName}&service=${service}&status=approved",
         failure: "https://neon-seahorse-b85142.netlify.app/payment-result?clientName=${clientName}&service=${service}&status=rejected",
      },
      auto_return: "approved",
    },
    {
      headers: {
        Authorization: `Bearer ${functions.config().mp.token}`,
      },
    }
  );

  return {
    preferenceId: response.data.id,
    init_point: response.data.init_point,
  };
});

exports.mpWebhook = functions.https.onRequest(async (req, res) => {
  const paymentId = req.body.data.id;

  const payment = await axios.get(
    `https://api.mercadopago.com/v1/payments/${paymentId}`,
    {
      headers: {
        Authorization: `Bearer ${functions.config().mp.token}`,
      },
    }
  );

  if (payment.data.status === "approved") {
    const { barberId, dateKey, hourKey } = payment.data.metadata;

    await admin.database()
      .ref(`appointments/${barberId}/${dateKey}/${hourKey}`)
      .update({
        paymentStatus: "paid",
        status: "confirmed",
        depositPaid: payment.data.transaction_amount,
      });
  }

  res.sendStatus(200);
});
