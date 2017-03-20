Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    # match ':controller(/:action(/:id))', via: [ :get, :post, :patch, :delete]

    root 'homes#show'

    resource :login, only: [ :show, :create, :destroy]

    resource :home, only: [ :show]

    resource :tool, only: [ :show, :create, :update]

    resource :configuration, only: [] do
        resource :zbxproxy
        resource :zbxagent
        resource :snmp
    end

    resource :script, only: [] do
        resource :host
        resource :ping
        resource :snmptrap
    end

    resource :maintenance, only: [] do
        resource :factoryreset, only: [ :show, :update]
        resource :techsupport, only: [ :show, :new]
        resource :initialsetup
    end


end
