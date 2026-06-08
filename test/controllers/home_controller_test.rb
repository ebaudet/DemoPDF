require "test_helper"
require "pdf-reader"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows the PDF generation form" do
    get root_url

    assert_response :success
    assert_select ".panel-heading", text: "Generate PDF"
    assert_select "form[action='#{generatePdf_path}'][method='post']"
    assert_select "input[name='form_params[name]']"
    assert_select "input[name='form_params[age]']"
    assert_select "button[type='submit']", text: "Generate PDF"
    assert_select "img[src*='red-wall']"
  end

  test "generates a PDF containing submitted values" do
    post generatePdf_url, params: { form_params: { name: "Alice", age: 30 } }

    assert_response :success
    assert_equal "application/pdf", @response.media_type
    assert_match(/inline; filename="file_name\.pdf"/, @response.headers["Content-Disposition"])

    reader = PDF::Reader.new(StringIO.new(@response.body))
    text = reader.pages.map(&:text).join

    assert_equal 1, reader.page_count
    assert_includes text, "Alice"
    assert_includes text, "30"
  end

  test "generates a PDF when submitted values are blank" do
    post generatePdf_url, params: { form_params: { name: "", age: "" } }

    assert_response :success
    assert_equal "application/pdf", @response.media_type
  end

  test "rejects requests without form parameters" do
    post generatePdf_url

    assert_response :bad_request
  end
end
