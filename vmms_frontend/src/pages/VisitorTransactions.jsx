import React from 'react'
import TransactionsPage from '../components/transactions/TransactionsPage'

export default function VisitorTransactions() {
  return (
    <TransactionsPage
      personType="VISITOR"
      title="Visitor Transactions"
      detailPath="/visitors"
    />
  )
}
