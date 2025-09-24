# lib/tasks/golden.rake
require "fileutils"
require "json"

namespace :golden do
  # Minimal scrubber for volatile fields that change between runs
  SCRUB_KEYS = %w[id created_at updated_at].freeze

  def scrub(json)
    case json
    when Array
      json.map { |e| scrub(e) }
    when Hash
      json.reject { |k,_| SCRUB_KEYS.include?(k.to_s) }
          .transform_values { |v| scrub(v) }
    else
      json
    end
  end

  # Helper to hit controller endpoints internally via Rack::MockRequest
  def make_request(method, path, payload = {})
    app = Rails.application

    env = Rack::MockRequest.env_for(path,
      "REQUEST_METHOD" => method.to_s.upcase,
      "CONTENT_TYPE"   => "application/json",
      "HTTP_ACCEPT"    => "application/json",
      "HTTP_HOST"      => "localhost:3000",  # Add host header to avoid blocked host error
      "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest",  # Mark as AJAX to bypass CSRF
      input: payload.to_json
    )

    status, headers, body = app.call(env)

    # Extract response body
    raw_body = []
    body.each { |chunk| raw_body << chunk }
    response_body = raw_body.join

    [status.to_i, response_body]
  end

  desc "Capture golden API responses to specs/_golden/*.json"
  task capture: :environment do
    FileUtils.mkdir_p("specs/_golden")

    # Use deterministic IDs from dev:prime seeding
    open_session_id = 301
    drink_item_id   = 101  # Water
    food_item_id    = 201  # Burger

    scenarios = [
      {
        name: "drink_purchase_success",
        method: "POST",
        path: "/sessions/#{open_session_id}/drink_purchases",
        payload: { item_id: drink_item_id, quantity: 2 }
      },
      {
        name: "drink_purchase_insufficient_stock",
        method: "POST",
        path: "/sessions/#{open_session_id}/drink_purchases",
        payload: { item_id: drink_item_id, quantity: 999 }
      },
      {
        name: "food_purchase_success",
        method: "POST",
        path: "/sessions/#{open_session_id}/food_purchases",
        payload: { item_id: food_item_id, quantity: 1 }
      },
      {
        name: "food_purchase_insufficient_stock",
        method: "POST",
        path: "/sessions/#{open_session_id}/food_purchases",
        payload: { item_id: food_item_id, quantity: 999 }
      },
      {
        name: "session_show_with_purchases",
        method: "GET",
        path: "/sessions/#{open_session_id}",
        payload: {}
      }
    ]

    scenarios.each do |scenario|
      puts ">> Capturing #{scenario[:name]}..."

      status, raw_body = make_request(scenario[:method], scenario[:path], scenario[:payload])

      begin
        parsed = JSON.parse(raw_body)
      rescue JSON::ParserError => e
        puts "   Warning: Non-JSON response, saving raw body"
        parsed = { "_error" => "JSON parse failed", "_raw_body" => raw_body, "_parse_error" => e.message }
      end

      # Apply minimal scrubbing
      cleaned = scrub(parsed)
      pretty_json = JSON.pretty_generate(cleaned)

      # Write to golden file
      filepath = "specs/_golden/#{scenario[:name]}.json"
      File.write(filepath, pretty_json)

      puts "   ✓ Wrote #{filepath} (HTTP #{status})"
    end

    puts "✅ golden:capture complete. Files written to specs/_golden/"
  end

  desc "Run both dev:prime and golden:capture in sequence"
  task :full => [:environment] do
    Rake::Task["dev:prime"].invoke
    Rake::Task["golden:capture"].invoke
  end
end