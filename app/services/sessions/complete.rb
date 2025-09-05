module Sessions
  class Complete
    def self.call(session:, params:)
      new(session: session, params: params).call
    end

    def initialize(session:, params:)
      @session = session
      @params = params
    end

    def call
      # Ensure session is open
      unless @session.open?
        raise ArgumentError, "Session is not open"
      end

      # Update session with close time
      close_time = @params[:time_out] || Time.current
      
      # Validate time order
      if close_time <= @session.time_in
        raise ArgumentError, "time_out must be greater than time_in"
      end

      # Close the session
      @session.update!(time_out: close_time)

      # Create completed session record with all purchase data
      create_completed_session_archive

      @session
    end

    private

    def create_completed_session_archive
      receipt_data = ReceiptSerializer.new(@session).as_json

      CompletedSession.create!(
        session_id: @session.id,
        membership_id: @session.membership_id,
        table_id: @session.table_id,
        duration_mins: @session.duration_minutes,
        total_cost: @session.grand_total,
        price_per_min: @session.price_per_minute,
        receipt: receipt_data.to_json,
        completed_at: @session.time_out
      )
    end

    def session_params
      @params.permit(:time_out, :membership_id)
    end
  end
end

