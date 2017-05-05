-- Demonstration 5 - CTE
--Common table expressions

-- Another way of effetively creating a table
	-- A mechanism for defining a subquery that may be use elsewhere in a query
	-- A bit like a view
	-- can be referenced multiple times within the same query with just one definition
	-- Useful construstor to reduce lines of code, not really a performance enhancer
	-- Supports Recursion - with recursion you can get performance enhancement
		--		 eg. employees , you have managers, who are also employees

		--tSQL in resources

-- Step 1: Open a new query window to the TSQL database
USE TSQL;
GO
-- Step 2: Common Table Expressions
-- -- Select this query and execute it to show CTE Examples
WITH CTE_year AS
	(
	SELECT YEAR(orderdate) AS orderyear, custid -- get year and csutid
	FROM Sales.Orders
	)
SELECT orderyear, COUNT(DISTINCT custid) AS cust_count-- Count year and csutid -  number of distinct customer
FROM CTE_year
GROUP BY orderyear;

-- Step 3 Recursive CTE  - performance benefit of CTE
WITH EmpOrg_CTE AS

(SELECT empid, mgrid, lastname, firstname									 --anchor query
	FROM HR.Employees
WHERE empid = 5 -- starting "top" of tree. Change this to show other root employees
			-- willpick up employee then recursively go through CTE we created based on empid 5 (so 5 is probably like CEO)
UNION ALL
SELECT child.empid, child.mgrid, child.lastname, child.firstname -- recursive member which refers back to CTE
	FROM EmpOrg_CTE AS parent
	JOIN HR.Employees AS child
	ON child.mgrid=parent.empid
)
SELECT empid, mgrid, lastname, firstname --isolates root employee and everyone that works for them
FROM EmpOrg_CTE;

1:06

