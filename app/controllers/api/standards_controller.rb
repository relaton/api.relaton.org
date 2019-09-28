module Api
  class StandardsController < ApplicationController
    def show
      find_standard || render_unprocessable_entity(
        I18n.t("standards.unprocessable_entity"),
      )
    end

    private

    def find_standard
      if params[:code] && standard
        render(json: standard, format: params[:document_format], status: :ok)
      end
    end

    def standard
      @standard ||= Standard.find_or_fetch_by(
        code: params[:code], year: params[:year],
      )
    end

    def render_unprocessable_entity(message)
      render(json: { error: message }, status: :unprocessable_entity)
    end
  end
end
