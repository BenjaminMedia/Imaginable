module Imaginable
	module Routing
		def imaginable_routes
			namespace :imaginable do
				match '/ratio/:crop' => 'crops#ratio'
				resources :images do
					get  :info
					post :webhook
					resources :crops
				end
			end
		end
	end
end

::ActionDispatch::Routing::Mapper.send(:include, Imaginable::Routing)