module GooglePlaces
    require 'rest_client'

    def google_places(query, lat, lng)
        articles = ['the', 'a', 'and', 'an', 'at', 'of', 'or', 'are', 'in', 'by', 'restaurant', 'cafe']
        query = query.gsub(/[']/i, '')
        query = query.gsub(/[^0-9a-z ]/i, ' ')
        query = (query.downcase.split - articles).join(' ')
        api_key = YAML.load_file('config/config.yml')['google_places_api_key']
        raw_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?name=%s&location=%s,%s&radius=20000&types=restaurant|bakery|bar|cafe|food|meal_takeaway|meal_delivery|night_club&sensor=false&key=%s" % [CGI::escape(query), lat, lng, api_key]
        encoded_url = URI.encode(raw_url)  # raw_url is invalid due to pipes
        data = JSON.parse(RestClient.get encoded_url, :accept => :json).with_indifferent_access
        results = []
        data[:results].each do |place|
            result = {}
            result[:formatted_address] = place[:vicinity] if place[:vicinity]
            result[:lng] = place[:geometry][:location][:lng] if place[:geometry][:location][:lng]
            result[:lat] = place[:geometry][:location][:lat] if place[:geometry][:location][:lat]
            result[:name] = place[:name] if place[:name]
            result[:price] = place[:price_level] if place[:price_level]
            result[:reference] = place[:reference] if place[:reference]
            result[:google_id] = place[:id] if place[:id]
            results.push result.with_indifferent_access
        end
        results
    end

    def google_places_details(reference)
        api_key = YAML.load_file('config/config.yml')['google_places_api_key']
        url = "https://maps.googleapis.com/maps/api/place/details/json?reference=%s&sensor=false&key=%s" % [reference, api_key]
        data = JSON.parse(RestClient.get url, :accept => :json).with_indifferent_access
        location = data[:result]
        result = {}
        result[:formatted_address] = location[:formatted_address] if location[:formatted_address]
        result[:phone] = location[:formatted_phone_number] if location[:formatted_phone_number]
        result[:website] = location[:website] if location[:website]
        location[:address_components].each do |component|
            types = component[:types]
            key = case 
            when types.include?('street_number')
                :street_number
            when types.include?('route')
                :street
            when types.include?('sublocality')
                :neighborhood
            when types.include?('locality')
                :city
            when types.include?('administrative_area_level_1')
                :state
            when types.include?('country')
                :country
            when types.include?('postal_code')
                :zip_code
            end
            result[key] = component[:short_name] if key
        end

        result[:hours] = []
        unless location[:opening_hours].nil?
            if location[:opening_hours][:periods]
                location[:opening_hours][:periods].each do |period|
                    hours = {}

                    unless period[:open].nil?
                        open_day = period[:open][:day]
                        open_time = period[:open][:time]
                        @open_in_minutes = to_minutes(open_day, open_time)
                        hours[:open_in_minutes] = @open_in_minutes

                        hours[:open_day] = open_day
                        hours[:open_time] = open_time
                    end

                    unless period[:close].nil?
                        close_day = period[:close][:day]
                        close_time = period[:close][:time]
                        close_in_minutes = to_minutes(close_day, close_time)
                        close_in_minutes += 60 * 24 * 7 if @open_in_minutes && close_in_minutes < @open_in_minutes
                        hours[:close_in_minutes] = close_in_minutes

                        hours[:close_day] = close_day
                        hours[:close_time] = close_time
                    end
                    result[:hours].push(hours)
                end
            end
        end
        result
    end

    def to_minutes(day, time)
        day = day.to_i
        time = time.to_i
        day_in_minutes = day * 60 * 24
        time_in_minutes = time / 100 * 60 + time % 100
        day_in_minutes + time_in_minutes
    end
end