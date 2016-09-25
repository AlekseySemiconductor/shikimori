describe VideoExtractor::UrlExtractor do
  describe '#call' do
    subject(:extract) { VideoExtractor::UrlExtractor.call html }

    context 'direct' do
      let(:html) { 'http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7' }
      it { is_expected.to eq Url.new(html).without_protocol.to_s }
    end

    context 'short', vcr: { cassette_name: 'url_extractor' } do
      context 'with_dash' do
        let(:html) { 'http://vk.com/video-42313379_167267838' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded' }
      end

      context 'without_dash' do
        let(:html) { 'https://vk.com/video135375095_163446262' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=135375095&id=163446262&hash=8574b5f5752c28d4' }
      end
    end

    context 'frame' do
      let(:html) { '<iframe width="607" src="' + extracted_url + '" height="360" frameborder="0"></iframe>' }
      let(:extracted_url) { '//vk.com/video_ext.php?oid=-42313379&id=167267838&hash=a941d75eea176ded' }
      it { is_expected.to eq extracted_url }
    end

    context 'strip' do
      let(:html) { ' http://vk.com/video_ext.php?oid=-11230840&id=164793125&hash=c8f8109b2c0341d7 ' }
      it { is_expected.to eq Url.new(html.strip).without_protocol.to_s }
    end

    describe 'vk_1' do
      let(:html) { '<iframe src="http://vk.com/video_ext.php?oid=-31193397&id=165152640&hash=924605cf891257c2&hd=1" width="730" height="480" frameborder="0"></iframe>' }
      it { is_expected.to eq '//vk.com/video_ext.php?oid=-31193397&id=165152640&hash=924605cf891257c2' }
    end

    describe 'vk_2' do
      let(:html) { '<iframe src="http://vkontakte.ru/video_ext.php?oid=154832837&id=161773398&hash=3c74648f3d5c6cfc&hd=3" width="730" height="480" frameborder="0"></iframe>' }
      it { is_expected.to eq '//vkontakte.ru/video_ext.php?oid=154832837&id=161773398&hash=3c74648f3d5c6cfc' }
    end

    describe 'vk_3' do
      let(:html) { '<iframe src="http://vk.com/video_ext.php?oid=31645372&amp;id=163523215&amp;hash=3fba843aaeb2a8ae&amp;hd=1" width="730" height="480" frameborder="0"></iframe>' }
      it { is_expected.to eq '//vk.com/video_ext.php?oid=31645372&id=163523215&hash=3fba843aaeb2a8ae' }
    end

    describe 'vk - remove misc parameters from url' do
      context '&hd=' do
        let(:html) { 'http://vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc&hd=1' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc' }
      end

      context '&other=' do
        let(:html) { 'http://vk.com/video_ext.php?oid=36842689&qwe=vbn&id=163317311&hash=e446fa5312813ebc&zxc=1' }
        it { is_expected.to eq '//vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc' }
      end
    end

    describe 'myvi_1' do
      let(:html) { '<object style="height: 390px; width: 640px"><param name="movie" value="http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0"><param name="allowFullScreen" value="true"><param name="allowScriptAccess" value="always"><embed src="http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="730" height="480"></object>' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0' }
    end

    describe 'myvi_2' do
      let(:html) { '<object style="width: 640px; height: 390px"><param name="allowFullScreen" value="true"/><param name="allowScriptAccess" value="always" /><param name="movie" value="http://myvi.ru/ru/flash/player/pre/oCJCcZPAwDviOuI-cOd-JrhfCmNXN_Z8j1E4-AfyYvpDRsgS_SwGRg2SBXhTpEZs30" /><param name="flashVars" value="kgzp=replace" /><embed src="http://myvi.ru/ru/flash/player/pre/oCJCcZPAwDviOuI-cOd-JrhfCmNXN_Z8j1E4-AfyYvpDRsgS_SwGRg2SBXhTpEZs30" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="730" height="480" flashVars="kgzp=replace"></object>' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/oCJCcZPAwDviOuI-cOd-JrhfCmNXN_Z8j1E4-AfyYvpDRsgS_SwGRg2SBXhTpEZs30' }
    end

    describe 'myvi_3' do
      let(:html) { '<iframe width="640" height="450" src="//myvi.tv/embed/html/oeBRkeha50wjXJIEU75wbYvUhlv4siaYE0KFla8kRgTHedQxAysFOs2B_yAWy3Tu80" frameborder="0" allowfullscreen></iframe>' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/oeBRkeha50wjXJIEU75wbYvUhlv4siaYE0KFla8kRgTHedQxAysFOs2B_yAWy3Tu80' }
    end

    describe 'myvi_4' do
      let(:html) { '<iframe width="640" height="450" src="http://myvi.ru/player/flash/o-yLxiEDfwHkdkERps0Ol8xsewC-jd-DQ-g5RR1EkMf2kwIfTBIScHSFJW4DvGJOu0hk]" frameborder="0" allowfullscreen></iframe>' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/o-yLxiEDfwHkdkERps0Ol8xsewC-jd-DQ-g5RR1EkMf2kwIfTBIScHSFJW4DvGJOu0hk' }
    end

    describe 'myvi_5' do
      let(:html) { '<iframe width="640" height="450" src="http://myvi.ru/player/flash/oPwYcE0DkIR7BuZ4Hjy-K97LXKJIgvwcsQQV3JDcss3LCRw294HoJ4fgXpSby1Q5lS2QxY125VvU1|http://myvi.ru/player/flash/oiLWME7qo9O3ragh7JC_fq2nr-f51DLt98_60sos3gbiY1ufb4hPA30whqpGE8VVjlVMzhdCsZgM1" frameborder="0" allowfullscreen></iframe>' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/oiLWME7qo9O3ragh7JC_fq2nr-f51DLt98_60sos3gbiY1ufb4hPA30whqpGE8VVjlVMzhdCsZgM1' }
    end

    describe 'myvi_6' do
      let(:html) { 'http://myvi.tv/embed/html/o2uWMvJRKqAyXG2EJUGGwUUKZwjleODmTYy0zGlks1-J5IO6Aexc_mKSgpudtZ7Zn0' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/o2uWMvJRKqAyXG2EJUGGwUUKZwjleODmTYy0zGlks1-J5IO6Aexc_mKSgpudtZ7Zn0' }
    end

    describe 'myvi_7' do
      let(:html) { 'http://myvi.ru/player/embed/html/preloader.swf?id=ooS23CgoxYNdHcm9FqwDb664Lbqhd1v7gyl7jDKc3O1xQ3-g0VOYjzoru3F35w6Ia0' }
      it { is_expected.to eq '//myvi.ru/player/embed/html/ooS23CgoxYNdHcm9FqwDb664Lbqhd1v7gyl7jDKc3O1xQ3-g0VOYjzoru3F35w6Ia0' }
    end

    describe 'mail_ru_1' do
      let(:html) { '<iframe src="http://api.video.mail.ru/videos/embed/mail/bel_comp1/14985/16397.html" width="730" height="480" frameborder="0"></iframe>' }
      it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/bel_comp1/14985/16397.html' }
    end

    describe 'mail_ru_2' do
      let(:html) { '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" width="730" height="480" id="movie_name" align="middle"><param name="movie" value="http://my9.imgsmail.ru/r/video2/uvpv3.swf?3"/><param name="flashvars" value="movieSrc=mail/bel_comp1/14985/15939&autoplay=0" /><param name="allowFullScreen" value="true" /><param name="AllowScriptAccess" value="always" /><!--[if !IE]>--><object type="application/x-shockwave-flash" data="http://my9.imgsmail.ru/r/video2/uvpv3.swf?3" width="730" height="480"><param name="movie" value="http://my9.imgsmail.ru/r/video2/uvpv3.swf?3"/><param name="flashvars" value="movieSrc=mail/bel_comp1/14985/15939&autoplay=0" /><param name="allowFullScreen" value="true" /><param name="AllowScriptAccess" value="always" /><!--<![endif]--><a href="http://www.adobe.com/go/getflash"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player"/></a><!--[if !IE]>--></object><!--<![endif]--></object>' }
      it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/bel_comp1/14985/15939.html' }
    end

    describe 'mail_ru_3' do
      let(:html) { '<embed src="http://img.mail.ru/r/video2/player_v2.swf?par=http://video.mail.ru/mail/ol4ik87.87/1123/$3816" flashvars="orig=2" width="730" height="480" allowfullscreen="true" wmode="opaque"/>' }
      it { is_expected.to eq '//img.mail.ru/r/video2/player_v2.swf?par=http://video.mail.ru/mail/ol4ik87.87/1123/$3816' }
    end

    describe 'mail_ru_4' do
      let(:html) { '<iframe src="https://videoapi.my.mail.ru/videos/embed/mail/allenwolker91/11052/11071.html" width="626" height="367" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>' }
      it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/allenwolker91/11052/11071.html' }
    end

    describe 'mail_ru_5' do
      let(:html) { 'http://my.mail.ru/mail/allenwolker91/video/11052/11071.html' }
      it { is_expected.to eq '//videoapi.my.mail.ru/videos/embed/mail/allenwolker91/11052/11071.html' }
    end

    describe 'rutube_1' do
      let(:html) { '<iframe type="text/html" width="730" height="480" src="http://rutube.ru/video/embed/6504640" frameborder="0"></iframe>' }
      it { is_expected.to eq '//rutube.ru/video/embed/6504640' }
    end

    describe 'rutube_2' do
      let(:html) { '<OBJECT width="730" height="480"><PARAM name="movie" value="http://video.rutube.ru/28c276bcec9a0619affa8e2443551b32"></PARAM><PARAM name="wmode" value="window"></PARAM><PARAM name="allowFullScreen" value="true"></PARAM><EMBED src="http://video.rutube.ru/28c276bcec9a0619affa8e2443551b32" type="application/x-shockwave-flash" wmode="window" width="730" height="480" allowFullScreen="true" ></EMBED></OBJECT>' }
      it { is_expected.to eq '//video.rutube.ru/28c276bcec9a0619affa8e2443551b32' }
    end

    describe 'rutube_3' do
      let(:html) { '<iframe width="730" height="480" src="http://rutube.ru/embed/6127963" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen scrolling="no"> </iframe>' }
      it { is_expected.to eq '//rutube.ru/embed/6127963' }
    end

    describe 'rutube_4' do
      let(:html) { '<iframe width="730" height="480" src="//rutube.ru/video/embed/6661157" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowfullscreen></iframe>' }
      it { is_expected.to eq '//rutube.ru/video/embed/6661157' }
    end

    describe 'rutube_5' do
      let(:html) { 'http://rutube.ru/tracks/2300012.html?v=8c8bbdc632726555649d45c2c6a273c0' }
      it { is_expected.to eq '//video.rutube.ru/8c8bbdc632726555649d45c2c6a273c0' }
    end

    describe 'rutube_6' do
      let(:html) { '<iframe width="720" height="405" src="//rutube.ru/play/embed/7300160?wmode=opaque&amp;autoStart=true" frameborder="0" webkitallowfullscreen="" mozallowfullscreen="" allowfullscreen="" id="video_frame"></iframe>' }
      it { is_expected.to eq '//rutube.ru/play/embed/7300160' }
    end

    describe 'sibnet_1' do
      let(:html) { '<iframe width="730" height="480" src="http://video.sibnet.ru/shell.php?videoid=1186077" frameborder="0" scrolling="no" allowfullscreen></iframe>' }
      it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1186077' }
    end

    describe 'sibnet_2' do
      let(:html) { 'http://data10.video.sibnet.ru/13/88/40/1388407.flv' }
      it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1388407' }
    end

    describe 'sibnet_3' do
      let(:html) { 'http://data17.video.sibnet.ru/71/08/710879.flv?st=WASnDgyViN6hucAYde9nlw&e=1349319000&format=mp4&start=0' }
      it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=710879' }
    end

    describe 'sibnet_4' do
      let(:html) { 'http://data9.video.sibnet.ru/12/24/22/1224221.mp4?st=FRf7r1A0LxkpPBmuFybKXA&e=1375711000' }
      it { is_expected.to eq '//video.sibnet.ru/shell.php?videoid=1224221' }
    end

    describe 'kiwi_1' do
      let(:html) { '<iframe title="Kiwi player" width="730" height="480" src="http://v.kiwi.kz/v2/s3jf896ex7h9/" frameborder="0" allowfullscreen></iframe>' }
      it { is_expected.to eq '//v.kiwi.kz/v2/s3jf896ex7h9/' }
    end

    describe 'kiwi_2' do
      let(:html) { '<object id="main_player_object" width="730" height="480"> <param name="wmode" value="opaque"/><param name="movie" value="http://p.kiwi.kz/static/player2/player.swf?config=http://p.kiwi.kz/static/player2/video.txt&url=http://farm.kiwi.kz/v/yvb2eb5r6y71/%3Fsecret%3DxrUpVyacqXt8unyeBzN4%2Bw%3D%3D&poster=http://im6.asset.kwimg.kz/screenshots/normal/yv/yvb2eb5r6y71_2.jpg&title=Mawaru+Penguin+Drum+-+23+%D1%81%D0%B5%D1%80%D0%B8%D1%8F+%28%D1%80%D1%83%D1%81.+%D1%81%D1%83%D0%B1%D1%82.+Ad...&redirect=http://kiwi.kz/watch/yvb2eb5r6y71/&page=http://kiwi.kz/watch/yvb2eb5r6y71/&embed=%3Ciframe+title%3D%22Kiwi+player%22+width%3D%22640%22+height%3D%22385%22+src%3D%22http%3A%2F%2Fv.kiwi.kz%2Fv2%2Fyvb2eb5r6y71%2F%22+frameborder%3D%220%22+allowfullscreen%3E%3C%2Fiframe%3E&related=http%3A%2F%2Fkiwi.kz%2Fapi%2Fmovies%2Frelated2%3Fhash%3Dyvb2eb5r6y71&like=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Flike%2F&unlike=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funlike%2F&fave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Ffave%2F&unfave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funfave%2F"> <param name="bgcolor" value="#000000"> <param name="allowFullScreen" value="true"> <param name="allowScriptAccess" value="always"> <embed wmode="opaque" id="main_player_embed" width="730" height="480" src="http://p.kiwi.kz/static/player2/player.swf" flashvars="config=http://p.kiwi.kz/static/player2/video.txt&url=http://farm.kiwi.kz/v/yvb2eb5r6y71/%3Fsecret%3DxrUpVyacqXt8unyeBzN4%2Bw%3D%3D&poster=http://im6.asset.kwimg.kz/screenshots/normal/yv/yvb2eb5r6y71_2.jpg&title=Mawaru+Penguin+Drum+-+23+%D1%81%D0%B5%D1%80%D0%B8%D1%8F+%28%D1%80%D1%83%D1%81.+%D1%81%D1%83%D0%B1%D1%82.+Ad...&redirect=http://kiwi.kz/watch/yvb2eb5r6y71/&page=http://kiwi.kz/watch/yvb2eb5r6y71/&embed=%3Ciframe+title%3D%22Kiwi+player%22+width%3D%22640%22+height%3D%22385%22+src%3D%22http%3A%2F%2Fv.kiwi.kz%2Fv2%2Fyvb2eb5r6y71%2F%22+frameborder%3D%220%22+allowfullscreen%3E%3C%2Fiframe%3E&related=http%3A%2F%2Fkiwi.kz%2Fapi%2Fmovies%2Frelated2%3Fhash%3Dyvb2eb5r6y71&like=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Flike%2F&unlike=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funlike%2F&fave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Ffave%2F&unfave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funfave%2F" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true"> </object>' }
      it { is_expected.to eq '//p.kiwi.kz/static/player2/player.swf?config=http://p.kiwi.kz/static/player2/video.txt&url=http://farm.kiwi.kz/v/yvb2eb5r6y71/%3Fsecret%3DxrUpVyacqXt8unyeBzN4%2Bw%3D%3D&poster=http://im6.asset.kwimg.kz/screenshots/normal/yv/yvb2eb5r6y71_2.jpg&title=Mawaru+Penguin+Drum+-+23+%D1%81%D0%B5%D1%80%D0%B8%D1%8F+%28%D1%80%D1%83%D1%81.+%D1%81%D1%83%D0%B1%D1%82.+Ad...&redirect=http://kiwi.kz/watch/yvb2eb5r6y71/&page=http://kiwi.kz/watch/yvb2eb5r6y71/&embed=%3Ciframe+title%3D%22Kiwi+player%22+width%3D%22640%22+height%3D%22385%22+src%3D%22http%3A%2F%2Fv.kiwi.kz%2Fv2%2Fyvb2eb5r6y71%2F%22+frameborder%3D%220%22+allowfullscreen%3E%3C%2Fiframe%3E&related=http%3A%2F%2Fkiwi.kz%2Fapi%2Fmovies%2Frelated2%3Fhash%3Dyvb2eb5r6y71&like=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Flike%2F&unlike=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funlike%2F&fave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Ffave%2F&unfave=http%3A%2F%2Fkiwi.kz%2Fwatch%2Fyvb2eb5r6y71%2Funfave%2F' }
    end

    describe 'youtube_1' do
      let(:html) { '<iframe width="730" height="480" src="http://www.youtube.com/embed/pOSilkJpCUI?feature=player_detailpage" frameborder="0" allowfullscreen></iframe>' }
      it { is_expected.to eq '//www.youtube.com/embed/pOSilkJpCUI?feature=player_detailpage' }
    end

    describe 'youtube_2' do
      let(:html) { '<object ><param name="wmode" value="opaque"/><param name="movie" value="http://www.youtube.com/v/CezgoEWr6U0?version=3&feature=player_detailpage"><param name="allowFullScreen" value="true"><param name="allowScriptAccess" value="always"><embed wmode="opaque" src="http://www.youtube.com/v/CezgoEWr6U0?version=3&feature=player_detailpage" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="730" height="480"></object>' }
      it { is_expected.to eq '//www.youtube.com/v/CezgoEWr6U0?version=3&feature=player_detailpage' }
    end

    describe 'youtube_3' do
      let(:html) { '<iframe width="730" height="480" src="//www.youtube.com/embed/pmLm4phNjB4" frameborder="0" allowfullscreen></iframe>' }
      it { is_expected.to eq '//www.youtube.com/embed/pmLm4phNjB4' }
    end

    describe 'video.yandex' do
      let(:html) { '<iframe width="730" height="480" frameborder="0" src="http://video.yandex.ru/iframe/dashaset08/pwq0ljt7p4.5028/"></iframe>' }
      it { is_expected.to eq '//video.yandex.ru/iframe/dashaset08/pwq0ljt7p4.5028/' }
    end

    describe 'i.ua' do
      let(:html) { '<OBJECT width="730" height="480"><PARAM name="movie" value="http://i.i.ua/video/evp.swf?V=504dd.ac6bb.59d.8e7cdf9.k29b27ead"></PARAM><EMBED src="http://i.i.ua/video/evp.swf?V=504dd.ac6bb.59d.8e7cdf9.k29b27ead" type="application/x-shockwave-flash" width="730" height="480"></EMBED></OBJECT>' }
      it { is_expected.to eq '//i.i.ua/video/evp.swf?V=504dd.ac6bb.59d.8e7cdf9.k29b27ead' }
    end

    describe 'flashx.tv' do
      let(:html) { '<IFRAME SRC="http://www.flashx.tv/embed-g5yfee5j0acc.html" FRAMEBORDER=0 MARGINWIDTH=0 MARGINHEIGHT=0 SCROLLING=NO WIDTH=852 HEIGHT=504></IFRAME>' }
      it { is_expected.to eq '//www.flashx.tv/embed-g5yfee5j0acc.html' }
    end

    describe 'vidbull.com' do
      let(:html) { '<IFRAME SRC="http://vidbull.com/embed-z8cyfxvok8nm-720x405.html" FRAMEBORDER=0 MARGINWIDTH=0 MARGINHEIGHT=0 SCROLLING=NO WIDTH=640 HEIGHT=360></IFRAME>' }
      it { is_expected.to eq '//vidbull.com/embed-z8cyfxvok8nm-720x405.html' }
    end

    describe 'mipix.eu' do
      let(:html) { '<iframe src="https://mipix.eu/translations/embed/274265" width="853" height="480" allowfullscreen frameborder="0"></iframe>' }
      it { is_expected.to eq '//mipix.eu/translations/embed/274265' }
    end

    describe 'smotret-anime.ru' do
      let(:html) { 'http://smotret-anime.ru/catalog/anime-kod-gias-vosstavshiy-lelush-2-2522/11-seriya-3784/russkie-subtitry-522965' }
      it { is_expected.to eq '//smotret-anime.ru/translations/embed/522965' }
    end

    describe 'smotret-anime.ru embed' do
      let(:html) { '<iframe src="https://smotret-anime.ru/translations/embed/522965" width="853" height="526" allowfullscreen frameborder="0"></iframe>' }
      it { is_expected.to eq '//smotret-anime.ru/translations/embed/522965' }
    end

    describe 'play.aniland.org' do
      let(:html) { 'http://play.aniland.org/2147401883?player=4' }
      it { is_expected.to eq '//play.aniland.org/2147401883?player=8' }
    end
  end
end
