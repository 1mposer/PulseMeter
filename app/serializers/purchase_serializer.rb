class PurchaseSerializer
  def initialize(purchase)
    @purchase = purchase
  end

  def as_json
    {
      id: @purchase.id,
      session_id: @purchase.session_id,
      item: {
        id: @purchase.item.id,
        name: @purchase.item.name,
        category: @purchase.item.category
      },
      quantity: @purchase.quantity,
      unit_price: format_money(@purchase.unit_price_at_sale),
      total_price: format_money(@purchase.total_price),
      created_at: @purchase.created_at.iso8601
    }
  end

  private

  def format_money(amount)
    return "0.00" if amount.nil?
    sprintf("%.2f", amount.to_f)
  end
end