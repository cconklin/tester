require "tester/runner"

describe Tester::Runner do
  let(:result) { Tester::Runner.run("some_command") }
  context "on executable files" do
    before do
      allow(Open3).to receive(:capture3).with("some_command").and_return(["out", "err", double("pid", exitstatus: 0, signaled?: false)])
    end
    it "should get the exit status" do
      expect(result.exitstatus).to eq(0)
    end
    it "should get the stdout" do
      expect(result.stdout).to eq("out")
    end
    it "should get the stderr" do
      expect(result.stderr).to eq("err")
    end
  end
  context "on a non-existent file" do
    before do
      allow(Open3).to receive(:capture3).and_raise(Errno::ENOENT)
    end
    it "should get the exit status" do
      expect(result.exitstatus).to eq(nil)
    end
    it "should get the stdout" do
      expect(result.stdout).to eq(Tester::Runner::NotExecutable)
    end
    it "should get the stderr" do
      expect(result.stderr).to eq(Tester::Runner::NotExecutable)
    end
  end
  context "on a non-executable file" do
    before do
      allow(Open3).to receive(:capture3).and_raise(Errno::EACCES)
    end
    it "should get the exit status" do
      expect(result.exitstatus).to eq(nil)
    end
    it "should get the stdout" do
      expect(result.stdout).to eq(Tester::Runner::NotExecutable)
    end
    it "should get the stderr" do
      expect(result.stderr).to eq(Tester::Runner::NotExecutable)
    end
  end
end
