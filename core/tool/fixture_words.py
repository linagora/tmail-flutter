"""Word lists used by eml_to_fixture.py to replace human text with real but
unrelated words of the same length (so fixtures stay readable for a reviewer
while the original wording is gone)."""

# Common English words, any length; grouped by length at import.
_ENGLISH = '''
a I
an at be by do go he if in is it me my no of on or so to up us we
act add age ago air all and any arm art ask bad bag bed big bit box boy bus but buy
can car cat cut day did dog dry due eat egg end eye far few fit fly for fun gas get
god got gun guy hat her him his hit hot how ice job joy key kid lab lay leg let lie
lot low man map may mix new nor not now odd off oil old one our out own pay pen per
put ran red run sad saw say sea see set she sit six sky son sun tax tea ten the tie
tip too top toy try two use van war was way wet who why win yes yet you zoo
able also area away baby back ball band bank base bear beat bell best bird blue boat
body bone book born both bowl busy cake call calm card care case cash cell chef city
club coat code cold come cook cool copy core cost crew dark data date deal deep desk
door down draw drop duck each earn east easy edge else even ever face fact fair fall
farm fast fear feel file fill film find fine fire fish five flat food foot form four
free from fuel full game gate gift girl give glad goal gold good gray grow hair half
hall hand hard have head hear heat help here high hill hold home hope hour huge idea
into iron item join jump just keep kind king kite lake land last late lead leaf left
less life lift like line list live long look lose loud love made mail main make many
mark meal meet menu mild milk mind mine miss mode moon more most move much must name
near neck need nest news next nice nine none note open over page pair park part pass
past path pick plan play plus pool poor port post pull pure push quiz race rain read
real rest rice rich ride ring rise road rock role roof room rope rule safe sale salt
same sand save seat seed seem sell send ship shoe shop show side sign silk sing size
skin slow snow soft soil song soon sort soup spot star stay step stop such suit sure
swim tail take talk tall team tell tent test text than that them then they thin this
time tiny tool tour town tree trip true tune turn type unit upon used very view vote
wait walk wall want warm wash wave wear week well west what when wide wife wild will
wind wine wing wise wish with wolf wood word work yard year your zero zone
about above actor adult after again agent agree ahead alarm album alive allow alone
along apple apply april arena arrow asset audio award basic beach begin below bench
birth black blank board brain bread break brick brief bring broad brown brush build
cable candy carry catch chair chalk chart cheap check chess chief child civil class
clean clear clock close cloud coach coast color count court cover craft cream crowd
daily dance delay depth dinner doubt dozen draft drama dream dress drink drive early
earth eight empty enjoy enter equal event every exact extra faith field fifth fifty
final first floor focus force frame fresh fruit funny glass globe grace grade grain
grand grape grass great green group guard guess guest guide happy heart heavy hello
honey horse hotel house human image index inner input issue jelly juice knife label
large laser later laugh layer learn lemon level light limit local lucky lunch magic
major maker march match mayor metal minor model money month motor mouse mouth movie
music never night noble noise north novel ocean offer often olive order other owner
paint panel paper party peace phone photo piano piece pilot place plain plane plant
plate point power press price pride print prize proud queen quick quiet radio raise
range rapid ratio reach ready right river robot round route royal rural salad scale
scene score sense seven shape share sharp sheep shelf shell shift shirt short sight
skill sleep small smart smile solid sound south space speed spend spoon sport staff
stage stamp stand start steam steel stone store storm story sugar sunny sweet table
taste teach thank theme thing three tiger title today topic total touch tower track
trade train treat trend trial truck trust truth twice uncle under union upper urban
usage value video visit voice water whale wheel white whole woman world worth young
action active advice almost animal answer anyone appear around arrive artist autumn
before better beyond border bottle bridge bright button camera candle castle center
chance change choice choose circle client coffee corner cotton couple course cousin
credit custom damage dealer decide degree design detail dinner direct doctor dollar
double driver easily editor effect effort eleven energy engine enough entire escape
evening expert family farmer father figure finger finish flight flower follow forest
forget friend future garden gentle global golden ground growth guitar health hidden
holder honest income island jacket jungle junior kitten ladder launch leader letter
listen little lovely manner market master matter member method middle minute mirror
modern moment mother motion museum nature nearby number object office orange palace
parent pencil people pepper period person planet player pocket policy potato powder
public purple puzzle rabbit reason record region remote repair report result return
ribbon rocket safety salmon sample school screen search season second secret senior
signal silver simple singer single sister smooth source spirit spring square stable
status street strong studio summer supply system tablet talent target temple tennis
thanks ticket timber tomato travel tunnel turtle twelve valley velvet visual volume
wallet window winner winter wonder yellow
account address advance airport already ancient another anybody arrange article
balance battery bedroom benefit bicycle blanket brother cabinet calendar capital
captain careful century chicken climate clothes collect comfort company compare
concert content country courage curtain current dancing deliver dessert diamond
dolphin drawing eastern economy example factory fashion feature finance fitness
forward freedom gallery general genuine harmony healthy history holiday horizon
husband imagine journey kitchen landing laundry leather library machine manager
meeting message million mission monitor morning musical natural network nothing
october package painter partner pattern perfect picture pioneer popular present
private problem product program project promise pumpkin quality quarter rainbow
reading regular science section service society soldier speaker station student
subject success support surface teacher theater thunder tonight traffic trouble
uniform unknown various village weather weekend welcome western whisper
absolute accurate activity actually addition airplane alphabet analysis anything
anywhere argument audience baseball beautiful birthday blizzard bookcase business
calendar campaign carefully category ceremony champion children chocolate cinnamon
comfortable complete computer consider continue creative customer daughter decision
delivery designer dinosaur directly discover distance document elephant emphasis
employee engineer envelope exercise familiar favorite festival football friendly
frontier gardener generous graduate grateful guidance hardware heritage hospital
industry interest internet kangaroo keyboard language learning lemonade location
magazine marathon mountain multiple national navigate notebook occasion opposite
painting peaceful pleasant position possible practice pressure princess progress
property question reaction remember research resource sandwich schedule seashore
security sentence shopping skeleton software solution starting strategy strength
superior teaspoon thousand together tomorrow umbrella universe vacation valuable
whatever woodland yourself
adventure afternoon agreement apartment attention available beginning breakfast
butterfly carpenter celebrate character classroom community condition confident
container crocodile dangerous delicious different direction education emergency
equipment excellent expensive important influence knowledge landscape lightning
marmalade necessary newspaper objective operation orchestra paragraph passenger
permanent pineapple pollution president principle professor recommend reference
religious satellite scientist something sometimes speedboat statement structure
submarine sunflower telephone temporary therefore thousands tradition treasurer
vegetable wonderful yesterday
accomplish appreciate atmosphere basketball binoculars blackboard boundaries
calculator chandelier commercial comparison consultant definitely democratic
department difference discussion efficiency electrical employment enterprise
everything excitement experience friendship generation government helicopter
historical illustrate impossible incredible individual innovation instrument
investment laboratory literature lumberjack management motorcycle mysterious
playground population production profession reflection restaurant revolution
strawberry successful technology television themselves thoroughly throughout
understand vocabulary watermelon whatsoever
accommodate achievement advertising agriculture alternative appointment
celebration combination comfortable competition concentrate consequence
contracting cooperation countryside description development dictionary
educational electricity engineering environment examination expectation
fingerprint grandmother grasshopper hummingbird imagination immediately
independent information institution instruction intelligent interesting
measurement neighborhood observation opportunity performance personality
photography preparation programming recognition refrigerator responsible
scholarship temperature theoretical traditional transparent unfortunate
'''.split()

# Common Vietnamese syllables (NFC), for words that carry diacritics.
_VIETNAMESE = '''
à á ạ ả ã ồ ở ừ ứ ý ổ ố ộ ơ ư
đi đó có là ra vì về sẽ đã để bé cả cá củ đủ gì hè kề lá lễ mẹ mở nề nữ ô tô
bàn bạn bếp bộ bữa cây cầu cửa chè chó chợ cũ dầu dễ dù đá đất đây đèn đến đồ đỏ
đũa gà gần giá giờ gỗ hai hoa học hỏi hồ hôm hơn khá khó kẹo lúa lửa mây mèo mới
mưa mười năm nắng nếu nói núi nữa nước ngày ngủ ngồi nhà nhỏ phố quà rau rất rồi
rừng sách sáng sau sân sông sớm sữa tay tết tốt trà trẻ trời trên tuổi vải vàng
vẫn vui vườn xa xe xanh xem xong yên áo ăn ấm ếch ốc ớt ước
bánh biển bóng bước buổi bưởi cảnh chiều chúng chuối cuộc cười dưới đường được
giấy giỏi giúp gương hoặc hướng khách không khỏe lượng mạnh miệng muốn người
nghĩ nghỉ ngoài nhanh nhiều những phòng quyển sương thích thuyền trường tiếng
trứng tuyệt tưởng vườn xuống
chuyện nghiệp thường trưởng khoảng nguyện thuyền giường xuyên
nghiêng nghiệm khuyến trường
'''.split()


def _by_length(words):
    groups = {}
    for word in words:
        groups.setdefault(len(word), []).append(word)
    return {length: sorted(set(group)) for length, group in groups.items()}


ENGLISH_BY_LENGTH = _by_length(_ENGLISH)
VIETNAMESE_BY_LENGTH = _by_length(_VIETNAMESE)
