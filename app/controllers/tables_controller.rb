class TablesController < ApplicationController
  def show
    # Mock data for now - will be replaced with real data later
    @table = {
      id: params[:id],
      name: "Table #{params[:id]}",
      status: ['available', 'running'].sample,
      started_at: 30.minutes.ago.iso8601,
      price_per_minute: 0.50
    }

    render partial: "tables/drawer", locals: { table: @table }, layout: false
  end
end