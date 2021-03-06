class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @conversation = Conversation.find(params[:id])
    @user = interlocutor(@conversation)
    @receiver = interlocutor(@conversation)
    @messages = @conversation.messages.order(created_at: :asc)
    @message = Message.new
    @messages_with_file = @conversation.messages.with_file.order(created_at: :desc).paginate(page: params[:page], per_page: 12)
  end

  def index #listing chat notifications
    @conversations = Conversation.where("conversations.recipient_id = ? OR conversations.sender_id = ?", current_user, current_user)
    current_user.reset_new_chat_notifications
  end

  private

    def conversation_params
      params.permit(:sender_id, :recipient_id)
    end

    def interlocutor(conversation)
      current_user == conversation.recipient ? conversation.sender : conversation.recipient
    end
end
