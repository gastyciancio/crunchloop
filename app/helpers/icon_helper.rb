# frozen_string_literal: true

module IconHelper
  def icon(name, **args)
    svg =
      File.open("app/assets/images/icons/#{name}.svg", 'rb') do |file|
        raw file.read
      end
    tag.i(**args) do
      svg
    end
  end
end
