let cardFormInitialized = false;
let payjpInstance = null;
let payjpElements = null;
let numberElement = null;
let expiryElement = null;
let cvcElement = null;
let submitHandler = null;

function cleanupCardForm() {
  if (numberElement) {
    try {
      numberElement.unmount();
    } catch (e) {}
    numberElement = null;
  }
  if (expiryElement) {
    try {
      expiryElement.unmount();
    } catch (e) {}
    expiryElement = null;
  }
  if (cvcElement) {
    try {
      cvcElement.unmount();
    } catch (e) {}
    cvcElement = null;
  }
  if (submitHandler) {
    const form = document.getElementById('charge-form');
    if (form) {
      form.removeEventListener('submit', submitHandler);
    }
    submitHandler = null;
  }
  
  // マウント先のDOMをクリア
  const numberForm = document.getElementById('number-form');
  const expiryForm = document.getElementById('expiry-form');
  const cvcForm = document.getElementById('cvc-form');
  if (numberForm) numberForm.innerHTML = '';
  if (expiryForm) expiryForm.innerHTML = '';
  if (cvcForm) cvcForm.innerHTML = '';
  
  payjpElements = null;
  cardFormInitialized = false;
}

document.addEventListener('turbo:before-cache', function() {
  cleanupCardForm();
});

document.addEventListener('turbo:load', function() {
  cleanupCardForm();
  setTimeout(initializeCardForm, 200);
});

document.addEventListener('turbo:render', function() {
  cleanupCardForm();
  setTimeout(initializeCardForm, 200);
});

document.addEventListener('DOMContentLoaded', function() {
  setTimeout(initializeCardForm, 200);
});

window.addEventListener('pageshow', function(event) {
  if (event.persisted) {
    cleanupCardForm();
    setTimeout(initializeCardForm, 200);
  }
});

function initializeCardForm() {
  const form = document.getElementById('charge-form');
  if (!form) {
    return;
  }

  if (cardFormInitialized) {
    return;
  }

  if (typeof Payjp === 'undefined') {
    setTimeout(initializeCardForm, 100);
    return;
  }

  if (typeof gon === 'undefined' || !gon.public_key) {
    console.error('PAY.JP公開鍵が設定されていません');
    return;
  }

  const publicKey = gon.public_key;

  // Payjpインスタンスは一度だけ作成し再利用する
  if (!payjpInstance) {
    payjpInstance = Payjp(publicKey);
  }

  payjpElements = payjpInstance.elements();
  numberElement = payjpElements.create('cardNumber');
  expiryElement = payjpElements.create('cardExpiry');
  cvcElement = payjpElements.create('cardCvc');

  const numberForm = document.getElementById('number-form');
  const expiryForm = document.getElementById('expiry-form');
  const cvcForm = document.getElementById('cvc-form');

  if (numberForm && expiryForm && cvcForm) {
    numberElement.mount('#number-form');
    expiryElement.mount('#expiry-form');
    cvcElement.mount('#cvc-form');
  } else {
    console.error('PAY.JP Elementsのマウント先が見つかりません');
    return;
  }

  submitHandler = function(event) {
    event.preventDefault();

    payjpInstance.createToken(numberElement).then(function(response) {
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

        cleanupCardForm();
        form.submit();
      }
    });
  };

  form.addEventListener('submit', submitHandler);

  cardFormInitialized = true;
}

