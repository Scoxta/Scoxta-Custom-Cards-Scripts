--Custom Hero?
local s,id=GetID()
function s.initial_effect(c)
	--search
local register=function(what)
	return function(...)
		local params={...}
		local tp=params[1]
		if Duel.GetFlagEffect(tp,id)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SetFlagEffectLabel(tp,id,1)
		end
		return what(...)
	end
end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.spop2)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCategory(CATEGORY_DICE)
	e3:SetCode(EFFECT_TOSS_DICE_CHOOSE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return Duel.GetFlagEffect(ep,id)>0 and Duel.GetFlagEffectLabel(ep,id)>0 end)
	e3:SetTarget(s.tg)
	--e4:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end

s.listed_names={58481572}

function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spfilter2(c)
	return c:IsCode(58481572)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end

function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
			local dc={Duel.GetDiceResult()}
			local ac=1
			local ct=(ev&0xff)
			if ct==2 then
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e4:SetRange(LOCATION_MZONE)
				e4:SetCode(EFFECT_SELF_DESTROY)
				c:RegisterEffect(e4)
			end
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,1,PLAYER_ALL,0)
end

function s.diceop2(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[0]~=cid  and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local dc={Duel.GetDiceResult()}
			local ac=1
			local ct=(ev&0xff)+(ev>>16)
			Duel.Hint(HINT_CARD,0,id)
			if ct>1 then
				local val,idx=Duel.AnnounceNumber(tp,table.unpack(dc,1,ct))
				ac=idx+1
			end
			if dc[ac]==1 or dc[ac]==3 or dc[ac]==5 then	dc[ac]=6
			else dc[ac]=1 end
		Duel.SetDiceResult(table.unpack(dc))
		s[0]=cid
	end
end


