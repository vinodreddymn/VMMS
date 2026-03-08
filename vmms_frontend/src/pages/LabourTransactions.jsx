import React from 'react'
import TransactionsPage from '../components/transactions/TransactionsPage'

export default function LabourTransactions() {
  return (
    <TransactionsPage
      personType="LABOUR"
      title="Labour Transactions"
      detailPath="/labour"
    />
  )
}
