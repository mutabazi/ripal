\name{byLength}
\alias{byLength}
\title{Get password length statistics from a passwords data frame}
\usage{
byLength(passwords)
}
\arguments{
  \item{passwords}{data frame of passwords with basewords
  already computed}
}
\value{
data frame of count & ratio of passwords by length, ordered
by length
}
\description{
Returns a data frame of the count and ratio of passwords by
length in the passwords data frame (ordered by length)
}
\examples{
passwords <- readPass("singles.org.txt")
countByLen <- byLength(passwords)
}

