class ReservationsController < ApplicationController
  before_action :load_mock_data

  def available
    @available_tables = calculate_available_tables
    render partial: "ui/reservations_available", layout: false
  end

  def active
    @active_reservations = @reservations.select { |r| %w[reserved seated].include?(r[:status]) }
    render partial: "ui/reservations_active", layout: false
  end

  def new
    @table_id = params[:table_id]
    @table_name = @tables.find { |t| t[:id].to_s == @table_id }&.dig(:name)
    render partial: "reservations/form", layout: false
  end

  def show
    @reservation = @reservations.find { |r| r[:id].to_s == params[:id] }
    render partial: "reservations/show", locals: { reservation: @reservation }, layout: false
  end

  # UI Stub Actions - return updated frames with toast messages
  def check_in
    # UI stub - would update reservation status to 'seated'
    flash[:notice] = "Guest checked in (UI stub)"
    redirect_to active_reservations_path
  end

  def end
    # UI stub - would end the reservation
    flash[:notice] = "Reservation ended (UI stub)"
    redirect_to active_reservations_path
  end

  def extend
    minutes = params[:minutes] || 15
    # Check for conflicts (UI stub)
    if rand < 0.3  # Simulate 30% conflict chance
      render html: "<div class='p-4 bg-red-900 text-white rounded'>Conflict at #{(Time.current + 2.hours).strftime('%H:%M')}. Try +5 or Move to T6.</div>".html_safe
    else
      flash[:notice] = "Extended by #{minutes} minutes (UI stub)"
      redirect_to active_reservations_path
    end
  end

  def cancel
    flash[:notice] = "Reservation cancelled (UI stub)"
    redirect_to active_reservations_path
  end

  def no_show
    flash[:notice] = "Marked as no-show (UI stub)"
    redirect_to active_reservations_path
  end

  private

  def load_mock_data
    # Mock data - replace with real data later
    @tables = [
      { id: 1, name: "Table 1", capacity: 4 },
      { id: 2, name: "Table 2", capacity: 2 },
      { id: 3, name: "Table 3", capacity: 6 },
      { id: 4, name: "Table 4", capacity: 4 },
      { id: 5, name: "VIP 1", capacity: 8 },
      { id: 6, name: "VIP 2", capacity: 10 }
    ]

    @reservations = [
      {
        id: 1,
        table_id: 1,
        guest_name: "John Doe",
        phone: "050-123-4567",
        start_time: 30.minutes.from_now,
        duration: 90,
        status: "reserved",
        notes: "Birthday celebration"
      },
      {
        id: 2,
        table_id: 3,
        guest_name: "Sarah Smith",
        phone: "055-987-6543",
        start_time: 10.minutes.ago,
        duration: 120,
        status: "seated",
        notes: nil
      },
      {
        id: 3,
        table_id: 5,
        guest_name: "Ahmed Ali",
        phone: "056-555-1234",
        start_time: 2.hours.from_now,
        duration: 120,
        status: "reserved",
        notes: "Corporate event"
      },
      {
        id: 4,
        table_id: 2,
        guest_name: "Maria Garcia",
        phone: "052-444-3333",
        start_time: 45.minutes.ago,
        duration: 60,
        status: "seated",
        notes: nil
      }
    ]
  end

  def calculate_available_tables
    @tables.map do |table|
      # Find next reservation for this table
      next_res = @reservations
        .select { |r| r[:table_id] == table[:id] && r[:start_time] > Time.current }
        .min_by { |r| r[:start_time] }

      free_until = if next_res
        (next_res[:start_time] - 10.minutes).strftime("%H:%M")
      else
        "End of day"
      end

      table.merge(free_until: free_until)
    end
  end
end