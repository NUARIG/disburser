class Rack::Attack
  # Cache store (using Rails cache by default)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle search requests by IP
  throttle('home', limit: 15, period: 60) do |req|
    if req.path == '/' && req.get?
      req.ip
    end
  end

  # Throttle login attempts for a given email parameter to 6 reqs/minute
  # Return the *normalized* email as a discriminator on POST /login requests
  Rack::Attack.throttle('limit logins per email', limit: 6, period: 60) do |req|
    if req.path == '/northwestern_users/sign_in' && req.post?
      # Normalize the email, using the same logic as your authentication process, to
      # protect against rate limit bypasses.
      req.params['northwestern_user']['username'].to_s.downcase.gsub(/\s+/, "")
    elsif req.path == '/external_users/sign_in' && req.post?  
      req.params['external_user']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end
  
  # # Alternative: throttle by both IP and search query to prevent repeated identical searches
  # throttle('search/ip/query', limit: 5, period: 60) do |req|
  #   if req.path == '/search' && req.get?
  #     "#{req.ip}:#{req.params['q']}" if req.params['q'].present?
  #   end
  # end
  #
  # # Block suspicious search patterns (customize based on your spam patterns)
  # blocklist('block bad search queries') do |req|
  #   # Block if search query contains suspicious patterns
  #   if req.path == '/search' && req.get?
  #     query = req.params['q'].to_s.downcase
  #
  #     # Add your spam patterns here
  #     spam_patterns = [
  #       /viagra/,
  #       /casino/,
  #       /\bhack\b/,
  #       /(http|https):\/\//,  # URLs in search
  #       /(.)\1{5,}/           # Repeated characters (e.g., "aaaaaa")
  #     ]
  #
  #     spam_patterns.any? { |pattern| query.match?(pattern) }
  #   end
  # end
  #
  # # Custom response for throttled requests
  # self.throttled_responder = lambda do |env|
  #   retry_after = (env['rack.attack.match_data'] || {})[:period]
  #   [
  #     429,
  #     {
  #       'Content-Type' => 'application/json',
  #       'Retry-After' => retry_after.to_s
  #     },
  #     [{ error: 'Too many requests. Please try again later.' }.to_json]
  #   ]
  # end
  #
  # # Custom response for blocked requests
  # self.blocklisted_responder = lambda do |env|
  #   [
  #     403,
  #     { 'Content-Type' => 'application/json' },
  #     [{ error: 'Forbidden. Your request was blocked.' }.to_json]
  #   ]
  # end
end