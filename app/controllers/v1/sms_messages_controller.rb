# frozen_string_literal: true

class V1::SmsMessagesController < ApplicationController
  before_action :set_sms_message, only: %i[delivery_status show resend]

  def index
    filtered_messages = SmsMessage.kept.order(updated_at: :desc)
    filtered_messages = filtered_messages.search_message_txt(params[:message_txt])   if params[:message_txt].present?
    filtered_messages = filtered_messages.search_phone(params[:phone])               if params[:phone].present?
    filtered_messages = filtered_messages.search_message_uuid(params[:message_uuid]) if params[:message_uuid].present?
    filtered_messages = filtered_messages.search_status(params[:status])             if params[:status].present?

    @pagy, @sms_messages = pagy(filtered_messages)
    render json: SmsMessageSerializer.new(
      @sms_messages,
      { meta: { pagination: pagy_metadata(@pagy) } }
    ), status: :ok
  end

  def create
    @sms_message = SmsMessage.new(message_params)
    if @sms_message.save
      SendSmsMessageWorker.perform_async(@sms_message.id)
      render json: { message: 'sms_message was successfully created and sent to the queue' }, status: :created
    else
      render json: { errors: @sms_message.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def show
    render json: SmsMessageSerializer.new(@sms_message), status: :ok
  end

  def delivery_status
    if @sms_message.update(update_params)
      render json: { message: 'sms_message was successfully updated' }, status: :ok
    else
      render json: { error: 'unable to update sms_message' }, status: :internal_server_error
    end
  end

  def resend
    if @sms_message.submitted? && params[:force].blank?
      render json: { message: 'The sms_message already has a message_uuid. To resend it anyway, use param `force=true`' }, status: :ok
    else
      SendSmsMessageWorker.perform_async(@sms_message.id)
      render json: { message: 'sms_message was successfully queued to resend' }, status: :ok
    end
  end

  private

  def update_params
    params.permit(:status)
  end

  def set_sms_message
    @sms_message =
      if params[:message_id]
        SmsMessage.find_by!(message_uuid: params[:message_id])
      else
        SmsMessage.find(params[:id])
      end
  end

  def message_params
    params.require(:sms_message).permit(:phone_number, :message_txt)
  end
end
