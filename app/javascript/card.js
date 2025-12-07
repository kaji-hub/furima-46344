let cardFormInitialized = false;

document.addEventListener('turbo:load', initializeCardForm);
document.addEventListener('turbo:render', initializeCardForm);

function initializeCardForm() {
  const form = document.getElementById('charge-form');
  if (!form) {
    cardFormInitialized = false;
    return;
  }

  if (cardFormInitialized) return;

  const publicKey = gon.public_key;
  if (!publicKey) return;

  const payjp = Payjp(publicKey);

  const elements = payjp.elements();
  const numberElement = elements.create('cardNumber');
  const expiryElement = elements.create('cardExpiry');
  const cvcElement = elements.create('cardCvc');

  numberElement.mount('#number-form');
  expiryElement.mount('#expiry-form');
  cvcElement.mount('#cvc-form');

  form.addEventListener('submit', function(event) {
    event.preventDefault();

    payjp.createToken(numberElement).then(function(response) {
      if (response.error) {
        alert(response.error.message);
      } else {
        const token = response.id;
        const tokenInput = document.querySelector('input[name="order_address[token]"]');
        if (tokenInput) {
          tokenInput.value = token;
        }

        numberElement.clear();
        expiryElement.clear();
        cvcElement.clear();

        cardFormInitialized = false;
        form.submit();
      }
    });
  });

  cardFormInitialized = true;
}

