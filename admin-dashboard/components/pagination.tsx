'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight } from 'lucide-react'

interface PaginationProps {
  readonly currentPage: number
  readonly totalPages: number
  readonly onPageChange: (page: number) => void
  readonly className?: string
}

export function Pagination({ currentPage, totalPages, onPageChange, className = '' }: PaginationProps) {
  const [pageInput, setPageInput] = useState('')

  const handlePageJump = (e: React.FormEvent) => {
    e.preventDefault()
    const page = Number.parseInt(pageInput, 10)
    if (page >= 1 && page <= totalPages) {
      onPageChange(page)
      setPageInput('')
    }
  }

  const goToFirstPage = () => onPageChange(1)
  const goToLastPage = () => onPageChange(totalPages)
  const goToPreviousPage = () => onPageChange(Math.max(1, currentPage - 1))
  const goToNextPage = () => onPageChange(Math.min(totalPages, currentPage + 1))

  // Generate page numbers to display
  const getPageNumbers = () => {
    const pages: (number | string)[] = []
    const maxVisible = 5

    if (totalPages <= maxVisible + 2) {
      // Show all pages if total is small
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i)
      }
    } else {
      // Always show first page
      pages.push(1)

      if (currentPage > 3) {
        pages.push('...')
      }

      // Show pages around current page
      const start = Math.max(2, currentPage - 1)
      const end = Math.min(totalPages - 1, currentPage + 1)

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }

      if (currentPage < totalPages - 2) {
        pages.push('...')
      }

      // Always show last page
      pages.push(totalPages)
    }

    return pages
  }

  if (totalPages <= 1) return null

  return (
    <div className={`flex items-center justify-between ${className}`}>
      <div className="text-sm text-slate-600">
        Page {currentPage} sur {totalPages}
      </div>

      <div className="flex items-center gap-2">
        {/* First page button */}
        <Button
          variant="outline"
          size="sm"
          onClick={goToFirstPage}
          disabled={currentPage === 1}
          className="hidden sm:flex"
        >
          <ChevronsLeft className="h-4 w-4" />
        </Button>

        {/* Previous button */}
        <Button
          variant="outline"
          size="sm"
          onClick={goToPreviousPage}
          disabled={currentPage === 1}
        >
          <ChevronLeft className="h-4 w-4" />
          <span className="hidden sm:inline ml-1">Précédent</span>
        </Button>

        {/* Page numbers */}
        <div className="hidden md:flex items-center gap-1">
          {getPageNumbers().map((page) => {
            if (page === '...') {
              return (
                <span key={`ellipsis-${Math.random()}`} className="px-2 text-slate-400">
                  ...
                </span>
              )
            }

            return (
              <Button
                key={`page-${page}`}
                variant={currentPage === page ? 'default' : 'outline'}
                size="sm"
                onClick={() => onPageChange(page as number)}
                className="min-w-[2.5rem]"
              >
                {page}
              </Button>
            )
          })}
        </div>

        {/* Next button */}
        <Button
          variant="outline"
          size="sm"
          onClick={goToNextPage}
          disabled={currentPage === totalPages}
        >
          <span className="hidden sm:inline mr-1">Suivant</span>
          <ChevronRight className="h-4 w-4" />
        </Button>

        {/* Last page button */}
        <Button
          variant="outline"
          size="sm"
          onClick={goToLastPage}
          disabled={currentPage === totalPages}
          className="hidden sm:flex"
        >
          <ChevronsRight className="h-4 w-4" />
        </Button>

        {/* Page jump input */}
        <form onSubmit={handlePageJump} className="hidden lg:flex items-center gap-2 ml-4 pl-4 border-l">
          <span className="text-sm text-slate-600 whitespace-nowrap">Aller à:</span>
          <Input
            type="number"
            min="1"
            max={totalPages}
            value={pageInput}
            onChange={(e) => setPageInput(e.target.value)}
            placeholder={`1-${totalPages}`}
            className="w-20 h-8 text-sm"
          />
          <Button type="submit" size="sm" variant="secondary">
            OK
          </Button>
        </form>
      </div>
    </div>
  )
}
