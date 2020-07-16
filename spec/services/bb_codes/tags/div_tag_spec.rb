describe BbCodes::Tags::DivTag do
  let(:tag) { BbCodes::Tags::DivTag.instance }
  subject { tag.format text }

  let(:text) { '[div]test[/div]' }
  it { is_expected.to eq '<div data-div>test</div>' }

  context 'class' do
    context 'single' do
      let(:text) { '[div=aaa]test[/div]' }
      it { is_expected.to eq '<div class="aaa" data-div>test</div>' }
    end

    context 'multiple' do
      let(:text) { '[div=aaa bb-cd_e]test[/div]' }
      it { is_expected.to eq '<div class="aaa bb-cd_e" data-div>test</div>' }
    end
  end

  context 'data-attribute' do
    context 'single' do
      context 'wo value' do
        let(:text) { '[div data-test]test[/div]' }
        it { is_expected.to eq '<div data-test data-div>test</div>' }
      end

      context 'with value' do
        let(:text) { '[div data-test=zxc]test[/div]' }
        it { is_expected.to eq '<div data-test=zxc data-div>test</div>' }
      end
    end

    context 'multiple' do
      let(:text) { '[div data-test data-fofo]test[/div]' }
      it { is_expected.to eq '<div data-test data-fofo data-div>test</div>' }
    end
  end

  context 'class + data-attribute' do
    let(:text) { '[div=aaa bb-cd_e data-test data-fofo]test[/div]' }
    it do
      is_expected.to eq(
        '<div class="aaa bb-cd_e" data-test data-fofo data-div>test</div>'
      )
    end
  end

  context 'nested' do
    let(:text) { '[div=cc-2a][div=c-column]test[/div][/div]' }
    it do
      is_expected.to eq(
        '<div class="cc-2a" data-div><div class="c-column" data-div>test</div></div>'
      )
    end
  end

  context 'cleanup classes' do
    let(:text) do
      "[div=aaa l-footer #{BbCodes::Tags::DivTag::FORBIDDEN_CLASSES.sample}]test[/div]"
    end
    it { is_expected.to eq '<div class="aaa" data-div>test</div>' }
  end

  context 'unbalanced tags' do
    let(:text) { '[div=cc-2a][div=c-column]test[/div]' }
    it { is_expected.to eq text }
  end
end
