require "spec_helper"

RSpec.describe ITunes::Store::Transporter::XML::Status do
  context "given a valid XML doc with a single status" do
    it "returns a Hash with a single status" do
      status = described_class.new.parse(fixture("status.vendor_id_123123").join(""))
      expect(status).to eq [{:apple_id=>"X9123X",
                             :vendor_id=>"123123",
                             :content_status=>
                             {:status=>"Unpolished",
                              :review_status=>"Ready-NotReviewed",
                              :itunes_connect_status=>"Other",
                              :store_status=>
                              {:not_on_store=>[], :on_store=>[], :ready_for_store=>["US"]},
                              :video_components=>
                              [{:name=>"Video",
                                :locale=>nil,
                                :status=>"In Review",
                                :delivered=>"2011-11-30 01:41:10"},
                               {:name=>"Audio",
                                :locale=>"en-US",
                                :status=>"In Review",
                                :delivered=>"2011-11-30 01:41:10"}]},
                             :info=>[{:created=>"2016-11-25 10:38:09", :status=>"Imported"}]}]

    end
  end

  context "given an invalid XML doc" do
    it "raises a ParseError" do
      expect {
        described_class.new.parse("<>")
        # Comment out to satisfy 1.9.3, it results in an "not well-formed" error
        #}.to raise_error( ITunes::Store::Transporter::ParseError, /invalid xml/i)
      }.to raise_error(ITunes::Store::Transporter::ParseError)
    end
  end

  context "given an XML doc that's not well-formed" do
    it "raises a ParseError" do
      expect {
        described_class.new.parse("<a><b></a>")
      }.to raise_error(ITunes::Store::Transporter::ParseError, /not well-formed/i)
    end
  end

  context "given an XML doc that contains an error message" do
    it "raises a ExecutionError containing the message and its code" do
      expect {
        described_class.new.parse(fixture("status.error_message").join("\n"))
      }.to raise_error(ITunes::Store::Transporter::ExecutionError) { |e|
        expect(e.errors.size).to eq 2
        expect(e.errors[0].message).to eq "Error message one."
        expect(e.errors[0].code).to eq -1234
        expect(e.errors[1].message).to eq "Error message two."
        expect(e.errors[1].code).to eq 9999
      }
    end
  end
end
