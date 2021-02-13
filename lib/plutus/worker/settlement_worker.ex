defmodule Plutus.Worker.SettlementWorker do
  use GenServer

  alias Plutus.Model.{Account,Income,Expense,Event, Transaction}
  alias Plutus.Types.Precompute
  alias Plutus.Common.Date, as: PDate

  require Logger

  @interval 3_600 # 1 hour

  def start_link() do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :settlement_worker
    )
  end

  def init(_) do
    Logger.debug("#{__MODULE__}: Initializing genserver for settlement processing")
    Process.send_after(self(), :settlement, 1_000)
    {:ok, nil}
  end

  def handle_info(:settlement, _) do
    Logger.debug("#{__MODULE__}: Starting settlement now")
    valid_accounts = Account.get_all_accounts() |> filter_valid_accounts()
    :ok = do_settlement(valid_accounts)
    Process.send_after(self(), :settlement, @interval)
    {:noreply, nil}
  end

  def do_settlement(accounts) do
    :ok
  end

  def filter_valid_accounts(accounts) do
    accounts
    |> Enum.filter(fn account -> 
      !is_nil(Map.get(account, :access_token, nil))
    end)
  end
end