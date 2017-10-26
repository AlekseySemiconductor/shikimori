describe BbCodes::Tags::CleanupNewLines do
  subject { BbCodes::Tags::CleanupNewLines.call text, tag }

  context 'div + quote' do
    let(:tag) { BbCodes::Tags::CleanupNewLines::TAGS }
    let(:text) { "\n\n[quote]\n\n[div=c-column;1;c]\n\ntest\n\n[/div]\n\n[/quote]\n\n" }
    it { is_expected.to eq "\n[quote]\n[div=c-column;1;c]\ntest\n[/div]\n[/quote]\n" }
  end

  context 'div' do
    let(:tag) { :div }

    context '\n\n<\div>' do
      let(:text) { "[div=cc-2][div]test\n\n[/div][/div]" }
      it { is_expected.to eq "[div=cc-2][div]test\n[/div][/div]" }
    end

    context '<div>\n\n' do
      let(:text) { "[div=c-column]\n\ntest[/div]" }
      it { is_expected.to eq "[div=c-column]\ntest[/div]" }
    end

    context '<\div>\n\n' do
      let(:text) { "[div=c-column]test[/div]\n\n" }
      it { is_expected.to eq "[div=c-column]test[/div]\n" }
    end

    context '\n\n<\div>' do
      let(:text) { "[div=c-column]test\n\n[/div]" }
      it { is_expected.to eq "[div=c-column]test\n[/div]" }
    end

    describe 'cleanups do not overlap with each other' do
      let(:text) { "[div=cc-2]\n\n[div=c-column]\n\ntest\n\n[/div]\n\n[/div]\n\n" }
      it { is_expected.to eq "[div=cc-2]\n[div=c-column]\ntest\n[/div]\n[/div]\n" }
    end
  end

  context 'quote' do
    let(:tag) { :quote }
    let(:text) { "\n\n[quote]\n\n[quote=c-column;1;c]\n\ntest\n\n[/quote]\n\n[/quote]\n\n" }
    it { is_expected.to eq "\n[quote]\n[quote=c-column;1;c]\ntest\n[/quote]\n[/quote]\n" }
  end
end
