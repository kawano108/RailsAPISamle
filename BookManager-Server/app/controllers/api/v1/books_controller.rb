# frozen_string_literal: true

class Api::V1::BooksController < ApplicationController
  before_action :jwt_authenticate

  rescue_from RuntimeError do |exception|
    render_failed_response(400, exception.message)
  end

  # 本メソッドは他で使わない一時変数が多いので行数が増えていますが、切り出す必要はないので警告を無視します。
  def index # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    limit = params[:limit].blank? ? 20 : params[:limit].to_i
    page = params[:page].blank? ? 1 : params[:page].to_i

    book_list = current_user.books.page(page).per(limit)
    if page <= book_list.total_pages
      render json: { status: 200,
                     result: book_list.map { |book| BooksSerializer.new(book).attributes },
                     total_count: book_list.total_count,
                     total_page: book_list.total_pages,
                     current_page: page,
                     limit: limit }
    else
      render_failed_response(400, I18n.t('errors.messages.missing_request_page'))
    end
  end

  def create
    book = current_user.books.build(book_params)
    if book.save
      render_success_response(200, BooksSerializer.new(book).attributes)
    else
      render_failed_response(400, book.errors.full_messages)
    end
  end

  def update
    book = current_user.books.find_by(id: params.require(:id))
    return render_failed_response(400, error: I18n.t('errors.messages.missing_update_book')) unless book

    if book.update({ id: params.require(:id) }.merge(book_params))
      render_success_response(200, BooksSerializer.new(book).attributes)
    else
      render_failed_response(400, book.errors.full_messages)
    end
  end

  private

  def book_params
    params.permit(:name, :image, :price, :purchase_date)
  end
end
