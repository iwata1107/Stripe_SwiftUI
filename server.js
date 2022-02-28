const express = require('express');
const app = express();
const { resolve } = require('path');

const stripe = require('stripe')('sk_test_51Jch2bCDF37nbEnLHA97n4s7kOl7nZnjO7ti2Y8aZnQbSrHpukfgAhNbC4TAEVMJAKeiivVBRscUQgXyM6Uk8jD100AWo0jA8A', {
  apiVersion: '2020-08-27',
  appInfo: {
    name: "stripe-samples/accept-a-payment/custom-payment-flow",
    version: "0.0.2",
    url: "https://github.com/stripe-samples"
  }
});

app.use(express.static('public'));
app.use(
  express.json({
    verify: function (req, res, buf) {
      if (req.originalUrl.startsWith('/webhook')) {
        req.rawBody = buf.toString();
      }
    },
  })
);
//ここまではテンプレート

//ルーティングの設定
app.get('/', (req, res) => {
  const path = resolve('public' + '/style.css');
  res.sendFile(path);
});


//'/config'でpublishablekeyをsendする
app.get('/config', (req, res) => {
  res.send({
    publishableKey: 'pk_test_51Jch2bCDF37nbEnL0zLYLdbTniQbQObPsjOWMpzPSkDEBQdBS4rs2mKAYgaLLYGGotCyd9Q3zWTEa56ohbCpqjga00nn0fWAQl',
  });
});


app.post('/create-payment-intent', async (req, res) => {
  const { paymentMethodType, currency, testamount} = req.body;

  const params = {
    payment_method_types: [paymentMethodType],
    amount: testamount,
    currency: currency,
    receipt_email: 'iwata.s1107@gmail.com',
  }
  
  if (paymentMethodType === 'acss_debit') {
    params.payment_method_options = {
      acss_debit: {
        mandate_options: {
          payment_schedule: 'sporadic',
          transaction_type: 'personal',
        },
      },
    }
  }

  try {
    //stripeにamount,currency,payment-method-typeを送っている（paramsは上で宣言している）
    const paymentIntent = await stripe.paymentIntents.create(params);
    res.send({
      clientSecret: paymentIntent.client_secret,
    });
  } catch (e) {
    return res.status(400).send({
      error: {
        message: e.message,
      },
    });
  }
});

app.post('/webhook', async (req, res) => {
  let data, eventType;

  if ('') {
    let event;
    let signature = req.headers['stripe-signature']; //webhookのシークレットキー入れる
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        'sk_test_51Jch2bCDF37nbEnLHA97n4s7kOl7nZnjO7ti2Y8aZnQbSrHpukfgAhNbC4TAEVMJAKeiivVBRscUQgXyM6Uk8jD100AWo0jA8A'
      );
    } catch (err) {
      console.log(`⚠️  Webhook signature verification failed.`);
      return res.sendStatus(400);
    }
    data = event.data;
    eventType = event.type;
  } else {
    data = req.body.data;
    eventType = req.body.type;
  }

  if (eventType === 'payment_intent.succeeded') {
    console.log('💰 Payment captured!');
  } else if (eventType === 'payment_intent.payment_failed') {
    console.log('❌ Payment failed.');
  }
  res.sendStatus(200);
});

app.listen(8000, () =>
  console.log(`Node server listening at http://localhost:8000`)
);
