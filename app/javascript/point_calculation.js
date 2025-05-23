document.addEventListener('DOMContentLoaded', () => {
  const redemptionPointInput = document.getElementById('redemption-point');
  const itemPriceDisplay = document.getElementById('item-price'); // 商品金額表示 (読み取り用)
  const usedPointsDisplay = document.getElementById('used-points');
  const finalPaymentAmountDisplay = document.getElementById('final-payment-amount');
  const pointInputErrorDisplay = document.getElementById('point-input-error');

  // gonから値を取得 (gonが正しく設定されている前提)
  // もしgonがない場合は、data属性など他の方法で値を取得してください。
  const userTotalPoints = parseInt(gon.user_total_points, 10) || 0;
  const itemPrice = parseInt(gon.item_price, 10) || 0;

  if (!redemptionPointInput || !itemPriceDisplay || !usedPointsDisplay || !finalPaymentAmountDisplay || !pointInputErrorDisplay) {
    // 必要な要素がページに存在しない場合は処理を中断
    console.warn('ポイント計算に必要な要素が見つかりません。');
    return;
  }

  redemptionPointInput.addEventListener('input', () => {
    console.log('redemptionPointInput.value:', redemptionPointInput.value);
    let pointsToUse = parseInt(redemptionPointInput.value, 10);
    pointInputErrorDisplay.textContent = ''; // エラーメッセージをクリア

    // --- クライアントサイドバリデーション ---
    if (isNaN(pointsToUse)) {
      pointsToUse = 0; // 不正な入力は0として扱う (またはエラー表示)
    }

    if (pointsToUse < 0) {
      pointInputErrorDisplay.textContent = '利用ポイントは0以上の値を入力してください。';
      pointsToUse = 0;
      // return; //ここで処理を中断させるか、0として計算を続けるか
    }

    if (pointsToUse > userTotalPoints) {
      pointInputErrorDisplay.textContent = `利用ポイントが所持ポイント(${userTotalPoints} Pt)を超えています。`;
      pointsToUse = userTotalPoints; // 所持ポイントを上限とするか、エラーで中断か
      redemptionPointInput.value = pointsToUse; // 入力値も修正
      // return;
    }

    if (pointsToUse > itemPrice) {
      pointInputErrorDisplay.textContent = `利用ポイントが商品金額(${itemPrice}円)を超えています。`;
      pointsToUse = itemPrice; // 商品金額を上限とする
      redemptionPointInput.value = pointsToUse; // 入力値も修正
      // return;
    }

    // --- 金額計算と表示更新 ---
    const discountAmount = pointsToUse;
    const finalPayment = itemPrice - discountAmount;

    usedPointsDisplay.textContent = `${discountAmount} Pt`;
    finalPaymentAmountDisplay.textContent = `¥${finalPayment.toLocaleString()}`;

    // 隠しフィールドにも値を設定する場合 (例)
    // const hiddenUsedPointsField = document.getElementById('hidden-used-points');
    // if (hiddenUsedPointsField) {
    //   hiddenUsedPointsField.value = discountAmount;
    // }
  });

  redemptionPointInput.dispatchEvent(new Event('input'));
});