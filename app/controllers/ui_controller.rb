class UiController < ApplicationController
  ALLOWED_PANELS = %w[tables consoles goods reservations].freeze

  def show
    panel = params[:panel]

    # Pass entity context to panels if provided
    @entity_type = params[:entity]
    @entity_id = params[:id]
    @entity_name = build_entity_name if @entity_type && @entity_id

    if ALLOWED_PANELS.include?(panel)
      render partial: "ui/#{panel}", layout: false
    else
      render partial: "ui/not_found", layout: false
    end
  end

  private

  def build_entity_name
    case @entity_type
    when 'table'
      "Table #{@entity_id}"
    when 'console'
      ["PS5 #1", "PS5 #2", "PS4 Pro", "Xbox Series X"][@entity_id.to_i % 4]
    else
      nil
    end
  end
end