require "test_helper"
require "pdf-reader"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should generate PDF" do
    post generatePdf_url, params: { form_params: { name: "Alice", age: 30 } }
    assert_response :success
    assert_equal "application/pdf", @response.media_type

    reader = PDF::Reader.new(StringIO.new(@response.body))
    text = reader.pages.map(&:text).join
    assert_includes text, "Alice"
    assert_includes text, "30"
  end
end