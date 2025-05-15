const pay = () => {
  const orderForm = document.getElementById('charge-form');
  if (!orderForm) return;

  const payjp = Payjp('pk_test_5b54d89290ed5613885a21ba'); // 公開鍵

  const elements = payjp.elements();
  const numberElement = elements.create('cardNumber');
  const expiryElement = elements.create('cardExpiry');
  const cvcElement = elements.create('cardCvc');

  numberElement.mount('#number-form');
  expiryElement.mount('#expiry-form');
  cvcElement.mount('#cvc-form'); // cvcElement をマウント

  const form = document.getElementById('charge-form');
  form.addEventListener("submit", (e) => {
    e.preventDefault(); // ★ ここに移動！デフォルトのフォーム送信を即座に止める

    payjp.createToken(numberElement).then((response) => {
      if (response.error) {
        console.error("Payjp Token Error:", response.error.message);
        alert("カード情報の入力に誤りがあります。\n" + response.error.message); // 例: ユーザーへのフィードバック
        // エラーメッセージ表示などの処理
      } else {
        const token = response.id;
        console.log("Payjp Token:", token);

        debugger
        // ★ トークンを隠しフィールドとしてフォームに追加
        const tokenInput = document.createElement("input");
        tokenInput.setAttribute("type", "hidden");
        tokenInput.setAttribute("name", "token");
        tokenInput.setAttribute("value", token);
        form.appendChild(tokenInput);

        // ★ フォームを送信
        form.submit();
      }
    }).catch((err) => {
        // Payjp API呼び出し自体でエラーが発生した場合
        console.error("Payjp API Error:", err);
        alert("決済システムとの通信中にエラーが発生しました。時間をおいてお試しください。"); // 例
    });
  });
};

window.addEventListener("turbo:load", pay);
window.addEventListener("DOMContentLoaded", pay); // 初回ロード用