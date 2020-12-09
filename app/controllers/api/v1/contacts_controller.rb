class Api::V1::ContactsController < Api::V1::ApiController

    before_action :set_contact, only: [:show, :update, :destroy]
    before_action :require_authorization!, only: [:show, :update,  :destroy]

    def index
        @contacts = current_user.contacts

        paginate json: @contacts, per_page: 10
    end

    def show
        render json: @contact
    end

    def create
        if contact_params.class == Array
            results = create_contatos_lote(contact_params)
            render json: results, status: :created
        else
            @contact = Contact.new(contact_params.merge(user: current_user))

            if @contact.save
                render json: @contact, status: :created
            else
                render json: @contact.errors, status: :unprocessable_entity
            end
        end
    end

    def update
        if @contact.update(contact_params)
            render json: @contact
        else
            render json: @contact.errors, status: :unprocessable_entity
        end
    end

    def destroy
        @contact.destroy
    end

    private
        def set_contact
            @contact = Contact.find(params[:id])
        end

        def contact_params
            if params.require(:contact).class == Array
                contacts = params.require(:contact).map do |contact|
                    contact.permit(:name, :email, :phone, :description)
                end
                return contacts
            else
                return params.require(:contact).permit(:name, :email, :phone, :description)
            end
        end

        def require_authorization!
            unless current_user == @contact.user
                render json: {}, status: :forbidden
            end
        end

        def create_contatos_lote(contacts)
            result = contacts.map do |contact|
                @contact = Contact.new(contact.merge(user: current_user))

                if @contact.save
                    @contact
                else
                    @contact.errors
                end
            end
            return result
        end
end