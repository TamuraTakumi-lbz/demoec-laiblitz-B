const pay = () => {
  const orderForm = document.getElementById('charge-form');
  if (!orderForm) return;

    // 既に初期化されていたら再初期化しない（重複防止）
    // const alreadyInitialized = orderForm.dataset.payjpInitialized === 'true';
    // if (alreadyInitialized) {
    //   console.log("Payjp already initialized, skipping");
    //   return;
    // }

  const publicKey = gon.public_key; 
  const payjp = Payjp(publicKey); 

  const elements = payjp.elements();
  const numberElement = elements.create('cardNumber');
  const expiryElement = elements.create('cardExpiry');
  const cvcElement = elements.create('cardCvc');

  numberElement.mount('#number-form');
  expiryElement.mount('#expiry-form');
  cvcElement.mount('#cvc-form'); 

  const form = document.getElementById('charge-form');
  form.addEventListener("submit", (e) => {
    e.preventDefault(); 

    payjp.createToken(numberElement).then((response) => {
      if (response.error) {
        console.error("Payjp Token Error:", response.error.message);
        alert("カード情報の入力に誤りがあります。\n" + response.error.message); 
      } else {
        const token = response.id;
        console.log("Payjp Token:", token);

        const tokenInput = document.createElement("input");
        tokenInput.setAttribute("type", "hidden");
        tokenInput.setAttribute("name", "token");
        tokenInput.setAttribute("value", token);
        form.appendChild(tokenInput);

        form.submit();
      }
    }).catch((err) => {
        console.error("Payjp API Error:", err);
        alert("決済システムとの通信中にエラーが発生しました。時間をおいてお試しください。"); // 例
    });
  });
};

window.addEventListener("DOMContentLoaded", pay); 