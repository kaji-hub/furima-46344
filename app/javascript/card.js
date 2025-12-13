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
    // PAY.JPスクリプトの読み込みを待つ（最大10秒）
    let retryCount = 0;
    const maxRetries = 100;
    const checkPayjp = setInterval(function() {
      retryCount++;
      if (typeof Payjp !== 'undefined') {
        clearInterval(checkPayjp);
        initializeCardForm();
      } else if (retryCount >= maxRetries) {
        clearInterval(checkPayjp);
        console.error('PAY.JPスクリプトの読み込みに失敗しました');
        alert('クレジットカード入力フォームの読み込みに失敗しました。ページを再読み込みしてください。');
        return;
      }
    }, 100);
    return;
  }

  // gon.public_keyの確認
  if (!gon || !gon.public_key) {
    console.error('PAY.JP公開鍵が設定されていません。環境変数PAYJP_PUBLIC_KEYを確認してください。');
    alert('クレジットカード機能の設定が正しくありません。管理者にお問い合わせください。');
    return;
  }

  const publicKey = gon.public_key;

  // Payjpインスタンスは一度だけ作成し再利用する
  if (!payjpInstance) {
    try {
      payjpInstance = Payjp(publicKey);
    } catch (error) {
      console.error('PAY.JPインスタンスの作成に失敗しました:', error);
      alert('クレジットカード入力フォームの初期化に失敗しました。ページを再読み込みしてください。');
      return;
    }
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

