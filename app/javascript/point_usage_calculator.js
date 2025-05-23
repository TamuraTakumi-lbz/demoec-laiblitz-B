// app/javascript/point_usage_calculator.js

// ページロード時またはTurboイベント時に実行
document.addEventListener('turbo:load', () => {
  const itemPriceElement = document.getElementById('item-price-display');
  const userPointsElement = document.getElementById('user-available-points-display');
  const pointInput = document.getElementById('redemption-point-input');
  const usedPointsDisplay = document.getElementById('used-points-display');
  const finalPaymentDisplay = document.getElementById('final-payment-amount-display');
  const pointErrorDisplay = document.getElementById('point-input-error');

  // クーポン関連の要素を取得
  const couponSelect = document.getElementById('selected_coupon_id_outside'); // クーポン選択プルダウン
  const hiddenCouponIdField = document.getElementById('hidden-selected-coupon-id-for-submission'); // クーポンID用隠しフィールド
  const hiddenPointsToRedeemField = document.getElementById('hidden-points-to-redeem-for-submission'); // ポイント利用額用隠しフィールド

  // 必要な要素がすべて存在するか確認
  // クーポン関連の要素は存在しない場合もあるので、チェックを分けるか、存在しない場合はnullとして扱う
  // 必須要素のチェック
  if (!itemPriceElement || !userPointsElement || !pointInput || !usedPointsDisplay || !finalPaymentDisplay || !pointErrorDisplay || !hiddenPointsToRedeemField || !hiddenCouponIdField) {
     console.error("必要な要素が見つかりませんでした。");
     console.log("Missing elements:", {
       itemPriceElement: !!itemPriceElement,
       userPointsElement: !!userPointsElement,
       pointInput: !!pointInput,
       usedPointsDisplay: !!usedPointsDisplay,
       finalPaymentDisplay: !!finalPaymentDisplay,
       pointErrorDisplay: !!pointErrorDisplay,
       hiddenPointsToRedeemField: !!hiddenPointsToRedeemField,
       couponSelect: !!couponSelect, // クーポンは必須ではないが、JSが依存する要素なのでチェック
       hiddenCouponIdField: !!hiddenCouponIdField // クーポンID用隠しフィールドは必須
     });
     // クーポン関連の要素がない場合は、ポイント計算のみ行うようにロジックを調整することも可能
     // 今はシンプルに必須要素としてすべてチェックします
     return;
   }


  const itemPrice = parseInt(itemPriceElement.dataset.itemPrice, 10);
  const availableUserPoints = parseInt(userPointsElement.dataset.userPoints, 10);

  // クーポン割引額を保持する変数
  let currentCouponDiscount = 0;

  // ポイントとクーポンを考慮した最終支払金額を計算・表示する関数
  const updateFinalPaymentDisplay = () => {
    let pointsToUse = parseInt(pointInput.value, 10) || 0; // 入力値がない場合は0

    // ポイント利用のバリデーションは input イベントリスナー内で既に行われているはずですが、念のためここでも最小限の確認
    if (pointsToUse < 0) pointsToUse = 0;
    if (pointsToUse > availableUserPoints) pointsToUse = availableUserPoints;
    if (pointsToUse > itemPrice) pointsToUse = itemPrice;

    // ポイント利用額とクーポン割引額を合計した割引額
    const totalDiscount = pointsToUse + currentCouponDiscount;

    // 最終支払金額を計算
    let finalPayment = itemPrice - totalDiscount;
    if (finalPayment < 0) {
      finalPayment = 0; // 支払額は負にならない
    }
     // PayJPなどの決済サービスで最低支払額がある場合はここで調整する
     // 例： if (finalPayment > 0 && finalPayment < MIN_PAYMENT_AMOUNT) { finalPayment = MIN_PAYMENT_AMOUNT; }


    // 表示を更新
    // ポイント利用額の表示はそのまま pointsToUse を使う
    usedPointsDisplay.textContent = `- ¥${pointsToUse.toLocaleString()}`; // ポイント利用額

    // クーポン割引額も表示したい場合はここに追加
    // 例: document.getElementById('coupon-discount-display').textContent = `- ¥${currentCouponDiscount.toLocaleString()}`;


    finalPaymentDisplay.textContent = `¥${finalPayment.toLocaleString()}`; // 最終支払金額

    // 隠しフィールドの値を更新
    hiddenPointsToRedeemField.value = pointsToUse;
    hiddenCouponIdField.value = couponSelect.value; // 選択されたクーポンIDを設定
  };

  // --- イベントリスナー ---

  // ポイント入力フィールドのイベントリスナー (既存ロジック + 最終支払額更新)
  pointInput.addEventListener('input', () => {
    let pointsToUse = parseInt(pointInput.value, 10);
    pointErrorDisplay.textContent = ''; // エラーをクリア

    if (isNaN(pointsToUse) || pointsToUse < 0) {
      pointsToUse = 0;
      if (isNaN(pointsToUse) && pointInput.value !== '') {
          pointErrorDisplay.textContent = '有効な数値を入力してください。';
      }
    }

    // 利用可能なポイント数の上限を確認
    if (pointsToUse > availableUserPoints) {
      pointErrorDisplay.textContent = `利用ポイントが所持ポイント(${availableUserPoints.toLocaleString()} Pt)を超えています。`;
      pointsToUse = availableUserPoints;
      pointInput.value = pointsToUse; // 入力値も修正
    }

    // 商品金額を超えるポイントは利用できない（全額ポイント払い考慮）
    const maxPointsForThisItem = itemPrice;
    if (pointsToUse > maxPointsForThisItem) {
      pointErrorDisplay.textContent = `利用ポイントが商品金額(¥${itemPrice.toLocaleString()})を超えています。`;
      pointsToUse = maxPointsForThisItem;
      pointInput.value = pointsToUse; // 入力値も修正
    }

    // ポイント入力値を修正した場合、input要素のvalueを更新
    if (parseInt(pointInput.value, 10) !== pointsToUse) {
        pointInput.value = pointsToUse;
    }

    // 最終支払額の表示を更新
    updateFinalPaymentDisplay();
  });

  // クーポン選択プルダウンのイベントリスナー
  // クーポン選択プルダウンが存在する場合のみイベントリスナーを追加
  if (couponSelect) {
    couponSelect.addEventListener('change', () => {
      const selectedOption = couponSelect.options[couponSelect.selectedIndex];
      // data-discount属性から割引額を取得。属性がない場合（「クーポンを使わない」など）は0
      currentCouponDiscount = parseInt(selectedOption.dataset.discount, 10) || 0;

      // 選択されたクーポンIDを隠しフィールドに設定
      hiddenCouponIdField.value = selectedOption.value;

      // 最終支払額の表示を更新
      updateFinalPaymentDisplay();
    });
  }


  // --- 初期化処理 ---

  // ページロード時に最終支払金額を初期化表示
  // ポイント入力フィールドとクーポン選択プルダウンの初期値に基づいて計算
  // クーポン選択の初期値（selectedIndex 0 またはデフォルト選択値）から割引額を取得
  if (couponSelect) {
      const initialSelectedOption = couponSelect.options[couponSelect.selectedIndex];
      currentCouponDiscount = parseInt(initialSelectedOption.dataset.discount, 10) || 0;
      hiddenCouponIdField.value = initialSelectedOption.value; // 初期クーポンIDを隠しフィールドに設定
  } else {
      // クーポン選択がない場合、隠しフィールドの初期値は空文字列になっているはず
      hiddenCouponIdField.value = "";
  }

  // ポイント利用の初期値（通常は0）を隠しフィールドに設定
  hiddenPointsToRedeemField.value = parseInt(pointInput.value, 10) || 0;


  // 初回表示時に計算と表示を更新
  updateFinalPaymentDisplay();
});