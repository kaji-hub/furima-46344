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

// Turboイベントの処理
document.addEventListener('turbo:before-cache', function() {
  cleanupCardForm();
});

document.addEventListener('turbo:load', function() {
  cleanupCardForm();
  setTimeout(initializeCardForm, 300);
});

document.addEventListener('turbo:render', function() {
  cleanupCardForm();
  setTimeout(initializeCardForm, 300);
});

// 通常のページロード時の処理
document.addEventListener('DOMContentLoaded', function() {
  setTimeout(initializeCardForm, 300);
});

// ブラウザの戻る/進むボタン対応
window.addEventListener('pageshow', function(event) {
  if (event.persisted) {
    cleanupCardForm();
    setTimeout(initializeCardForm, 300);
  }
});

// ページが完全に読み込まれた後の処理（本番環境での保険）
if (document.readyState === 'complete') {
  setTimeout(initializeCardForm, 500);
} else {
  window.addEventListener('load', function() {
    setTimeout(initializeCardForm, 500);
  });
}

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
    try {
      numberElement.mount('#number-form');
      expiryElement.mount('#expiry-form');
      cvcElement.mount('#cvc-form');
      console.log('PAY.JP Elementsが正常にマウントされました');
    } catch (error) {
      console.error('PAY.JP Elementsのマウントに失敗しました:', error);
      // リトライ処理
      setTimeout(function() {
        try {
          if (numberForm && expiryForm && cvcForm) {
            numberElement.mount('#number-form');
            expiryElement.mount('#expiry-form');
            cvcElement.mount('#cvc-form');
            console.log('PAY.JP Elementsのリトライが成功しました');
          }
        } catch (retryError) {
          console.error('PAY.JP Elementsのリトライも失敗しました:', retryError);
          alert('クレジットカード入力フォームの初期化に失敗しました。ページを再読み込みしてください。');
        }
      }, 500);
      return;
    }
  } else {
    console.error('PAY.JP Elementsのマウント先が見つかりません', {
      numberForm: !!numberForm,
      expiryForm: !!expiryForm,
      cvcForm: !!cvcForm
    });
    // DOM要素が見つからない場合もリトライ
    setTimeout(initializeCardForm, 500);
    return;
  }

  submitHandler = function(event) {
    event.preventDefault();

    payjpInstance.createToken(numberElement).then(function(response) {
      if (response.error) {
        // PAY.JPのエラーが発生した場合でも、トークンを空のままフォームを送信
        // サーバー側のバリデーションで「Token can't be blank」エラーが表示される
        const tokenInput = document.querySelector('input[name="order_address[token]"]');
        if (tokenInput) {
          tokenInput.value = '';
        }
        
        cleanupCardForm();
        form.submit();
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
    }).catch(function(error) {
      // 予期しないエラーの場合も、トークンを空のままフォームを送信
      console.error('PAY.JP決済エラー:', error);
      const tokenInput = document.querySelector('input[name="order_address[token]"]');
      if (tokenInput) {
        tokenInput.value = '';
      }
      
      cleanupCardForm();
      form.submit();
    });
  };

  form.addEventListener('submit', submitHandler);

  cardFormInitialized = true;
}

