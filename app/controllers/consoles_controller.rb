class ConsolesController < ApplicationController
  def show
    # Mock data for now - will be replaced with real data later
    @console = {
      id: params[:id],
      name: ["PS5 #1", "PS5 #2", "PS4 Pro", "Xbox Series X"][params[:id].to_i % 4],
      status: ['available', 'running'].sample,
      started_at: 45.minutes.ago.iso8601,
      price_per_minute: 1.00
    }

    render partial: "consoles/drawer", locals: { console: @console }, layout: false
  end
end