require 'minitest/autorun'
require_relative './phonebook.rb'

include Phonebook

class TestPhonebook < MiniTest::Test

  describe Phonebook do

    let(:error) { /error/i }
    let(:success) { /success/i }
    let(:file) { "test.pb" }

    after do
      File.delete(file) if File.file?(file)
    end

    describe "Before the phonebook file has been created" do

      before do
        File.delete(file) if File.file?(file)
      end

      let(:args) { ["dave", "123", file] }

      it "should respond with an error when adding a record" do
        r = Phonebook.process_request(["add"] + args)
        r.must_match(error)
      end

      it "should respond with an error when changing a record" do
        r = Phonebook.process_request(["change"] + args)
        r.must_match(error)
      end

      it "should respond with an error when removing a record" do
        r = Phonebook.process_request(["remove"] + args)
        r.must_match(error)
      end

      it "should respond with an error when looking up a person" do
        r = Phonebook.process_request(["lookup", "Dave", file])
        r.must_match(error)
      end

      it "should respond with an error when looking up a number" do
        r = Phonebook.process_request(["reverse", "123", file])
        r.must_match(error)
      end

    end

    describe "creating a new pb" do

      before do
        File.delete(file) if File.file?(file)
      end

      after do
        File.delete(file) if File.file?(file)
      end

      it "should respond with 'created'" do
        r = Phonebook.process_request(["create", file])
        r.must_match(success)
      end

    end

    describe "basic phonebook operations" do

      before do
        Phonebook.process_request(["create", file])
      end

      after do
        File.delete(file) if File.file?(file)
      end

      it "should allow insertion of new entries" do
        r = Phonebook.process_request(["add", "dave", "123", file])
        r.must_match(success)
      end

      it "should not allow insertion of duplicate names" do
        Phonebook.process_request(["add", "dave", "123", file])
        r = Phonebook.process_request(["add", "dave", "321", file])
        r.must_match(error)
      end

      it "should not allow insertion of duplicate numbers" do
        Phonebook.process_request(["add", "sarah", "4567", file])
        r = Phonebook.process_request(["add", "kate", "4567", file])
        r.must_match(error)
      end

      it "should respond with an error when using non-spec commands" do
        r = Phonebook.process_request(["insert", "rebecca", "456", file])
        r.must_match(error)
      end

      describe "with entries input" do

        before do
          Phonebook.process_request(["add", "dave", "123", file])
        end

        it "should lookup previously entered values" do
          r = Phonebook.process_request(["lookup", "dave", file])
          r.must_match(/Dave/)
        end

        it "should allow reverse lookup of previously entered values" do
          r = Phonebook.process_request(["reverse", "123", file])
          r.must_match(/Dave/)
        end

        it "should allow removal of previously entered values" do
          r = Phonebook.process_request(["remove", "dave", file])
          r.must_match(success)
        end

        describe "and removed" do
          let(:matcherror) { /No matches/i }

          before do
            Phonebook.process_request(["remove", "dave", file])
          end

          it "should not allow lookup of removed entries" do
            r = Phonebook.process_request(["lookup", "dave", file])
            r.must_match(matcherror)
          end

          it "should not allow reverse lookup of removed entries" do
            r = Phonebook.process_request(["reverse", "123", file])
            r.must_match(matcherror)
          end

        end
      end
    end
  end
end
