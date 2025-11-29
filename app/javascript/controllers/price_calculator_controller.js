import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["priceInput", "addTaxPrice", "profit"]

  connect() {
    // ページ読み込み時に価格が既に入力されている場合、計算を実行
    if (this.priceInputTarget.value) {
      this.calculate()
    }
      this.priceInputTarget.addEventListener('input', () => this.calculate())
  }

  calculate() {
    const inputValue = this.priceInputTarget.value
    
    // 入力値を数値に変換（空の場合は0）
    const price = parseInt(inputValue, 10) || 0
    
    // 価格が300円以上9999999円以下の場合のみ計算
    if (price >= 300 && price <= 9999999) {
      // 手数料を計算（価格の10%、小数点以下切り捨て）
      const fee = Math.floor(price * 0.1)
      // 利益を計算（価格 - 手数料）
      const gain = price - fee
      // 手数料と利益を表示（カンマ区切りで表示）
      this.addTaxPriceTarget.textContent = fee.toLocaleString()
      this.profitTarget.textContent = gain.toLocaleString()
    } else if (inputValue === '') {
      // 入力が空の場合は表示をクリア
      this.addTaxPriceTarget.textContent = ''
      this.profitTarget.textContent = ''
    } else {
      // 範囲外の場合は表示をクリア
      this.addTaxPriceTarget.textContent = ''
      this.profitTarget.textContent = ''
    }
  }
}

