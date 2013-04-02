module Rack
  class Lotus
    module AuthorizationHelpers
      def current_person
        if session[:person_id]
          @current_person ||= Person.find_by_id(session[:person_id])
        end
      end
    end

    helpers AuthorizationHelpers
  end
end
