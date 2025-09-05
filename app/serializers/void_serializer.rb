class VoidSerializer
  def initialize(session)
    @session = session
  end

  def as_json
    {
      status: "voided",
      session_id: @session.id,
      voided_at: @session.voided_at&.iso8601,
      void_reason: @session.void_reason
    }
  end
end