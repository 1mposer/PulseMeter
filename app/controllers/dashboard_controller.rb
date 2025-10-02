class DashboardController < ApplicationController
  def index
    # Shell page - no data coupling
    # Initial panel can be set via params[:panel] for URL state
    @initial_panel = params[:panel] if %w[tables consoles goods reservations].include?(params[:panel])
  end
end