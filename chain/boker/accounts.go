//Tina链增加的特殊账号管理类
package boker

import (
	"github.com/Tinachain/Tina/chain/boker/protocol"
	"github.com/Tinachain/Tina/chain/common"
	_ "github.com/Tinachain/Tina/chain/log"
)

//帐号常量
const SystemAddress = "0xd7fd311c8f97349670963d87f37a68794dfa80ff"

var (
	SystemAccount     = common.HexToAddress(SystemAddress) //系统账户
	CommunityAccount  = common.HexToAddress(SystemAddress) //社区账户
	FoundationAccount = common.HexToAddress(SystemAddress) //基金账户
	TeamAccount       = common.HexToAddress(SystemAddress) //团队账户
)

//Tina链的账号管理
type AcccountLevel struct {
	level protocol.TxMajor
}
type BokerAccount struct {
	systemAccount     common.Address
	communityAccount  common.Address
	foundationAccount common.Address
	teamAccount       common.Address
}

func NewAccount() *BokerAccount {

	bokerAccount := new(BokerAccount)

	bokerAccount.systemAccount = SystemAccount
	bokerAccount.communityAccount = CommunityAccount
	bokerAccount.foundationAccount = FoundationAccount
	bokerAccount.teamAccount = TeamAccount

	return bokerAccount
}

func (a *BokerAccount) GetAccount(address common.Address) (protocol.TxMajor, error) {

	if address == a.systemAccount || address == a.communityAccount || address == a.foundationAccount || address == a.teamAccount {
		return protocol.Base, nil
	} else {
		return protocol.Normal, nil
	}
}

func (a *BokerAccount) GetTeamAccount() common.Address {

	return a.teamAccount
}
